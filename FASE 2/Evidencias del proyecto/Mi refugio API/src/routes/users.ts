import { Router } from 'express';
import pool from '../config/db';
import pbkdf2 from 'pbkdf2';
import crypto from 'crypto';

const router = Router();

/* ============================================================
   HELPERS
============================================================ */

const normalizeEmail = (value: any): string | null => {
    if (!value) return null;
    const normalized = String(value).trim().toLowerCase();
    return normalized || null;
};

const computeAge = (dateValue: any): number | null => {
    if (!dateValue) return null;
    const d = new Date(dateValue);
    if (Number.isNaN(d.getTime())) return null;
    const diff = Date.now() - d.getTime();
    const age = new Date(diff).getUTCFullYear() - 1970;
    return age >= 0 ? age : null;
};

const normalizeBirthday = (payload: any): any => {
    const value = payload?.birthday ?? payload?.birthdate ?? null;
    return value === "" ? null : value;
};
const hasBirthdayField = (payload: any): boolean =>
    !!payload && ("birthday" in payload || "birthdate" in payload);

const buildSafeUsername = (requested: string | undefined | null, fallbackEmail: string): string => {
    const base = (requested || fallbackEmail.split("@")[0] || "user").trim();
    return base || "user";
};

async function ensureUniqueWebUsername(username: string, fallbackEmail: string): Promise<string> {
    const base = buildSafeUsername(username, fallbackEmail);
    let candidate = base;
    let suffix = 1;

    // Intentar rápidamente unos sufijos deterministas antes de caer en UUID
    while (true) {
        const exists = await pool.query("SELECT 1 FROM web.auth_user WHERE username = $1 LIMIT 1", [candidate]);
        if (exists.rowCount === 0) {
            return candidate;
        }
        candidate = `${base}_${suffix++}`;
        if (suffix > 5) break;
    }

    // Fallback aleatorio para minimizar colisiones
    return `${base}_${crypto.randomUUID().slice(0, 8)}`;
}

// Hash PBKDF2 compatible con Django
const hashPasswordForDjango = (password: string): string => {
    const salt = crypto.randomBytes(12).toString('base64');
    const iterations = 100000;
    const derivedKey = pbkdf2.pbkdf2Sync(password, salt, iterations, 32, 'sha256');
    const hash = derivedKey.toString('base64');
    return `pbkdf2_sha256$${iterations}$${salt}$${hash}`;
};

const findWebUserByIdentifier = async (identifier: string) => {
    const result = await pool.query(
        `
        SELECT *
        FROM web.auth_user
        WHERE external_id = $1
           OR id::text = $1
           OR lower(email) = lower($1)
        LIMIT 1
        `,
        [identifier]
    );
    return result.rows[0] || null;
};

/* ============================================================
   CREAR USUARIO EN DJANGO
============================================================ */

async function createUserInWeb(user: any) {
    const safeEmail =
        normalizeEmail(user.email) ||
        normalizeEmail(`${(user.username || "user").toLowerCase()}@nomail.local`) ||
        "user@nomail.local";

    const fullName = user.full_name?.trim() || user.username || "Usuario";
    const parts = fullName.split(/\s+/);
    const firstName = parts[0] || "Usuario";
    const lastName = parts.slice(1).join(" ") || "SinApellido";
    const uniqueUsername = await ensureUniqueWebUsername(user.username, safeEmail);
    const roleValue = (user.role || "").toString().toLowerCase();
    const isSuperuser = roleValue === "admin";
    const isStaff = isSuperuser || roleValue === "staff";

    const externalId =
        user.external_id ||
        user.id ||
        crypto.randomUUID();

    const passwordHash = hashPasswordForDjango("TEMP1234");

    // Si ya existe por email, actualizamos external_id y datos básicos
    const existing = await pool.query(
        "SELECT id, external_id, is_superuser, is_staff FROM web.auth_user WHERE lower(email) = $1 LIMIT 1",
        [safeEmail]
    );

    const existingCount = existing?.rowCount ?? 0;

    if (existingCount > 0) {
        const current = existing.rows[0];
        const targetIsSuperuser = user.role ? isSuperuser : current.is_superuser;
        const targetIsStaff = user.role ? isStaff : current.is_staff;
        await pool.query(
            `
            UPDATE web.auth_user
            SET username = $1,
                first_name = $2,
                last_name = $3,
                external_id = COALESCE(external_id, $4),
                gender = $5,
                birthday = $6,
                is_superuser = $7,
                is_staff = $8
            WHERE id = $9
            `,
            [
                uniqueUsername,
                firstName,
                lastName,
                externalId,
                user.gender || null,
                user.birthday || user.birthdate || null,
                targetIsSuperuser,
                targetIsStaff,
                current.id,
            ]
        );
        return externalId;
    }

    await pool.query(
        `
        INSERT INTO web.auth_user 
        (username, password, first_name, last_name, email, external_id,
         is_superuser, is_staff, is_active, date_joined,
         gender, birthday)
        VALUES ($1,$2,$3,$4,$5,$6,$7,$8,true,NOW(),$9,$10)
        `,
        [
            uniqueUsername,
            passwordHash,
            firstName,
            lastName,
            safeEmail,
            externalId,
            isSuperuser,
            isStaff,
            user.gender || null,
            user.birthday || user.birthdate || null,
        ]
    );

    return externalId;
}

/* ============================================================
   CREAR USUARIO EN APP (UUID)
============================================================ */

async function createUserInApp(user: any) {
    const safeEmail =
        normalizeEmail(user.email) ||
        normalizeEmail(`${(user.username || "user").toLowerCase()}@nomail.local`) ||
        "user@nomail.local";
    const normalizedEmail = safeEmail;
    const externalId =
        user.external_id ||
        user.id ||
        crypto.randomUUID();

    await pool.query(
        `
        INSERT INTO app.users AS u
        (id, external_id, email, name, username, "password", role, 
         "createdAt", "updatedAt", gender, birthdate)
        VALUES ($1,$2,$3,$4,$5,$6,$7,NOW(),NOW(),$8,$9)
        ON CONFLICT (email) DO UPDATE
        SET name = EXCLUDED.name,
            username = EXCLUDED.username,
            role = EXCLUDED.role,
            gender = EXCLUDED.gender,
            birthdate = EXCLUDED.birthdate,
            external_id = COALESCE(u.external_id, EXCLUDED.external_id),
            "updatedAt" = NOW()
        `,
        [
            externalId,
            externalId,
            normalizedEmail,
            user.full_name || user.username || "Usuario",
            user.username || normalizedEmail.split("@")[0],
            "SYNC",
            user.role || "member",
            user.gender || null,
            user.birthday || user.birthdate || null,
        ]
    );
}

/* ============================================================
   GET USERS (solo lectura + normalización desktop)
============================================================ */

router.get("/", async (req, res) => {
    try {
        const [webResult, appResult] = await Promise.all([
            pool.query("SELECT * FROM web.auth_user"),
            pool.query("SELECT * FROM app.users"),
        ]);

        // Normalizar DJANGO
        const webUsers = webResult.rows.map((u) => ({
            email: normalizeEmail(u.email) || "",
            web: {
                id: u.id,
                external_id: u.external_id || null,
                username: u.username,
                full_name: `${u.first_name} ${u.last_name}`.trim(),
                role: u.is_superuser ? "admin" : u.is_staff ? "staff" : "user",
                gender: u.gender,
                birthday: u.birthday,
                age: computeAge(u.birthday),
                status: u.is_active ? "Activo" : "Inactivo",
                password_hash: u.password || null,
            },
        }));

        // Normalizar APP
        const appUsers = appResult.rows.map((u) => ({
            email: normalizeEmail(u.email) || "",
            app: {
                id: u.id,
                external_id: u.external_id || u.id || null,
                username: u.username,
                full_name: u.name,
                role: u.role,
                gender: u.gender,
                birthday: u.birthdate,
                age: computeAge(u.birthdate),
                avatarUrl: u.avatarUrl,
                status: "Activo",
                password_hash:
                    typeof u.password === "string" &&
                    (u.password.includes("$") || u.password === "SYNC")
                        ? u.password
                        : null,
            },
        }));

        // Unificar por external_id o email
        const usersMap = new Map<string, any>();
        const emailIndex = new Map<string, string>();

        const upsertUser = (key: string, email: string, updater: (entry: any) => void) => {
            const existingKey = usersMap.has(key) ? key : emailIndex.get(email);
            const finalKey = existingKey || key;
            const current = usersMap.get(finalKey) || { email, web: null, app: null, external_id: null };
            updater(current);
            current.email = current.email || email;
            if (!current.external_id) {
                current.external_id = current.web?.external_id || current.app?.external_id || null;
            }
            usersMap.set(finalKey, current);
            if (email) {
                emailIndex.set(email, finalKey);
            }
        };

        for (const user of webUsers) {
            const key = user.web.external_id || user.email;
            if (!key) continue;
            upsertUser(key, user.email, (entry) => {
                entry.web = user.web;
                entry.external_id = entry.external_id || user.web.external_id || null;
            });
        }

        for (const user of appUsers) {
            const key = user.app.external_id || user.email;
            if (!key) continue;
            upsertUser(key, user.email, (entry) => {
                entry.app = user.app;
                entry.external_id = entry.external_id || user.app.external_id || null;
            });
        }

        const unifiedUsers = Array.from(usersMap.values());

        /* ============================================================
           NORMALIZAR SALIDA PLANA PARA APP DESKTOP
        ============================================================ */

        const finalUsers = unifiedUsers.map((u) => {
            const src = u.app || u.web || {};
            const externalId =
                u.external_id ||
                u.app?.external_id ||
                u.web?.external_id ||
                u.app?.id ||
                u.web?.id ||
                null;
            return {
                id: externalId || src?.id,
                external_id: externalId,
                email: u.email,
                username: src.username,
                full_name: src.full_name,
                role: src.role || "user",
                status: src.status || "Activo",
                gender: src.gender ?? "No especificado",
                birthday: src.birthday ?? null,
                birthdate: src.birthday ?? null,
                age: src.age ?? null,
                password_hash: src.password_hash ?? null,
            };
        });

        finalUsers.sort((a, b) => (a.email || "").localeCompare(b.email || ""));

        res.json(finalUsers);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: "Error al obtener usuarios" });
    }
});

/* ============================================================
   SYNC USERS (manual, evitando duplicados)
============================================================ */

router.post("/sync", async (_req, res) => {
    try {
        const [webResult, appResult] = await Promise.all([
            pool.query("SELECT * FROM web.auth_user"),
            pool.query("SELECT * FROM app.users"),
        ]);

        const webByEmail = new Map<string, any>();
        const appByEmail = new Map<string, any>();

        for (const u of webResult.rows) {
            const email = normalizeEmail(u.email);
            if (!email) continue;
            webByEmail.set(email, u);
        }

        for (const u of appResult.rows) {
            const email = normalizeEmail(u.email);
            if (!email) continue;
            appByEmail.set(email, u);
        }

        const emails = new Set<string>([
            ...Array.from(webByEmail.keys()),
            ...Array.from(appByEmail.keys()),
        ]);

        const actions: Array<{ email: string; action: string }> = [];

        for (const email of emails) {
            const webUser = webByEmail.get(email) || null;
            const appUser = appByEmail.get(email) || null;

            const externalId =
                webUser?.external_id ||
                appUser?.external_id ||
                appUser?.id ||
                crypto.randomUUID();

            if (webUser && webUser.external_id !== externalId) {
                await pool.query(
                    "UPDATE web.auth_user SET external_id = $1 WHERE id = $2",
                    [externalId, webUser.id]
                );
                actions.push({ email, action: "update_web_external_id" });
            }

            if (appUser && appUser.external_id !== externalId) {
                await pool.query(
                    `UPDATE app.users SET external_id = $1, "updatedAt" = NOW() WHERE id = $2`,
                    [externalId, appUser.id]
                );
                actions.push({ email, action: "update_app_external_id" });
            }

            if (webUser && !appUser) {
                await createUserInApp({
                    ...webUser,
                    email,
                    external_id: externalId,
                    role: webUser.is_superuser ? "admin" : webUser.is_staff ? "staff" : "user",
                    full_name: `${webUser.first_name || ""} ${webUser.last_name || ""}`.trim(),
                });
                actions.push({ email, action: "web_to_app" });
            }

            if (appUser && !webUser) {
                await createUserInWeb({
                    ...appUser,
                    email,
                    external_id: externalId,
                    role: appUser.role,
                    full_name: appUser.name || appUser.username,
                });
                actions.push({ email, action: "app_to_web" });
            }
        }

        res.json({ synced: actions.length, details: actions });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: "Error al sincronizar usuarios" });
    }
});

/* ============================================================
   CREATE USER (WEB → API)
============================================================ */

router.post("/", async (req, res) => {
    const { username, password, full_name, role, email, gender } = req.body;
    const birthdayValue = normalizeBirthday(req.body);

    const safeEmail =
        normalizeEmail(email) ||
        normalizeEmail(`${username || "user"}@nomail.local`) ||
        "user@nomail.local";
    const parts = (full_name || "").trim().split(/\s+/);

    const firstName = parts[0] || "Usuario";
    const lastName = parts.slice(1).join(" ") || "SinApellido";

    const isSuperuser = role === "admin";
    const isStaff = role === "admin" || role === "staff";
    const externalId = crypto.randomUUID();

    try {
        const passwordHash = hashPasswordForDjango(password);

        const result = await pool.query(
            `
            INSERT INTO web.auth_user
            (username, password, first_name, last_name, email, external_id,
             is_superuser, is_staff, is_active, date_joined,
             gender, birthday)
            VALUES ($1,$2,$3,$4,$5,$6,$7,$8,true,NOW(),$9,$10)
            RETURNING *
            `,
            [
                username,
                passwordHash,
                firstName,
                lastName,
                safeEmail,
                externalId,
                isSuperuser,
                isStaff,
                gender || null,
                birthdayValue,
            ]
        );

        const row = result.rows[0];

        await createUserInApp({
            email: row.email,
            username: row.username,
            full_name: `${row.first_name} ${row.last_name}`,
            role,
            gender,
            birthday: birthdayValue,
            external_id: externalId,
        });

        res.json({
            id: externalId,
            external_id: externalId,
            username: row.username,
            full_name: `${row.first_name} ${row.last_name}`,
            email: row.email,
            role,
            gender,
            birthday: birthdayValue,
            birthdate: birthdayValue,
            age: computeAge(birthdayValue),
            status: "Activo",
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: "Error al crear usuario" });
    }
});

/* ============================================================
   UPDATE USER
============================================================ */

router.put("/:id", async (req, res) => {
    const { id } = req.params;
    const { username, full_name, role, password, status, email, gender } = req.body;
    const birthdayProvided = hasBirthdayField(req.body);
    const birthdayValue = birthdayProvided ? normalizeBirthday(req.body) : undefined;

    try {
        const existingWeb = await findWebUserByIdentifier(id);
        if (!existingWeb) {
            return res.status(404).json({ error: "Usuario no encontrado" });
        }
        const oldEmail = normalizeEmail(existingWeb.email);
        const externalId = existingWeb.external_id || id || crypto.randomUUID();
        const normalizedNewEmail = email ? normalizeEmail(email) : undefined;

        let query = "UPDATE web.auth_user SET id = id";
        const values: any[] = [];
        let idx = 1;

        if (username) {
            query += `, username = $${idx++}`;
            values.push(username);
        }

        if (normalizedNewEmail) {
            query += `, email = $${idx++}`;
            values.push(normalizedNewEmail);
        }

        if (full_name) {
            const parts = full_name.trim().split(/\s+/);
            query += `, first_name = $${idx++}, last_name = $${idx++}`;
            values.push(parts[0]);
            values.push(parts.slice(1).join(" ") || "SinApellido");
        }

        if (role) {
            const isSuperuser = role === "admin";
            const isStaff = role === "admin" || role === "staff";
            query += `, is_superuser = $${idx++}, is_staff = $${idx++}`;
            values.push(isSuperuser);
            values.push(isStaff);
        }

        if (status) {
            query += `, is_active = $${idx++}`;
            values.push(status === "Activo");
        }

        if (gender !== undefined) {
            query += `, gender = $${idx++}`;
            values.push(gender);
        }

        if (birthdayProvided) {
            query += `, birthday = $${idx++}`;
            values.push(birthdayValue);
        }

        if (password) {
            query += `, password = $${idx++}`;
            values.push(hashPasswordForDjango(password));
        }

        query += `, external_id = COALESCE(external_id, $${idx++})`;
        values.push(externalId);

        query += ` WHERE id = $${idx} RETURNING *`;
        values.push(existingWeb.id);

        const result = await pool.query(query, values);
        const row = result.rows[0];

        // Actualizar APP
        const updates = [];
        const appValues = [];
        let appIdx = 1;

        if (full_name) {
            updates.push(`name = $${appIdx++}`);
            appValues.push(full_name);
        }

        if (username) {
            updates.push(`username = $${appIdx++}`);
            appValues.push(username);
        }

        if (role) {
            updates.push(`role = $${appIdx++}`);
            appValues.push(role);
        }

        if (gender !== undefined) {
            updates.push(`gender = $${appIdx++}`);
            appValues.push(gender);
        }

        if (birthdayProvided) {
            updates.push(`birthdate = $${appIdx++}`);
            appValues.push(birthdayValue);
        }

        if (normalizedNewEmail) {
            updates.push(`email = $${appIdx++}`);
            appValues.push(normalizedNewEmail);
        }

        updates.push(`external_id = COALESCE(external_id, $${appIdx++})`);
        appValues.push(externalId);

        if (updates.length > 0) {
            const whereClauses = [];
            if (externalId) {
                whereClauses.push(`external_id = $${appIdx++}`);
                appValues.push(externalId);
            }
            if (oldEmail) {
                whereClauses.push(`email = $${appIdx++}`);
                appValues.push(oldEmail);
            }

            const updateQuery = `
                UPDATE app.users
                SET ${updates.join(", ")}, "updatedAt" = NOW()
                WHERE ${whereClauses.join(" OR ")}
            `;
            await pool.query(updateQuery, appValues);
        }

        res.json({
            id: externalId,
            external_id: externalId,
            username: row.username,
            full_name: `${row.first_name} ${row.last_name}`,
            email: normalizedNewEmail || oldEmail,
            role: row.is_superuser ? "admin" : row.is_staff ? "staff" : "user",
            status: row.is_active ? "Activo" : "Inactivo",
            gender: row.gender,
            birthday: row.birthday,
            birthdate: row.birthday,
            age: computeAge(row.birthday),
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: "Error al actualizar usuario" });
    }
});

/* ============================================================
   DELETE
============================================================ */

router.delete("/:id", async (req, res) => {
    const { id } = req.params;

    try {
        const webUser = await findWebUserByIdentifier(id);
        if (!webUser) {
            return res.status(404).json({ error: "Usuario no encontrado" });
        }

        const email = normalizeEmail(webUser.email);
        const externalId = webUser.external_id || id || null;

        // 1. Borrar en Django
        await pool.query("DELETE FROM web.auth_user WHERE id = $1", [webUser.id]);

        // 2. Borrar también en APP (por external_id o email)
        const conditions = [];
        const values = [];
        let idx = 1;
        if (externalId) {
            conditions.push(`external_id = $${idx++}`);
            values.push(externalId);
        }
        if (email) {
            conditions.push(`email = $${idx++}`);
            values.push(email);
        }
        if (conditions.length > 0) {
            await pool.query(
                `DELETE FROM app.users WHERE ${conditions.join(" OR ")}`,
                values
            );
        }

        res.json({ success: true });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: "Error al eliminar usuario" });
    }
});


export default router;
