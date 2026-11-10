/**
 * Cliente HTTP asincrono para Mi Refugio Web.
 * Maneja CSRF, tokens JWT en memoria + cookies HttpOnly, refresco automatico 401
 * y polling con retroceso exponencial para tareas asincronas (HTTP 202).
 */
(function (global) {
  "use strict";

  const loadedScripts = new Map();
  let accessTokenInMemory = null;
  let refreshPromise = null;

  function getCookie(name) {
    if (!document.cookie) return "";
    const parts = document.cookie.split(";");
    for (let i = 0; i < parts.length; i += 1) {
      const part = parts[i].trim();
      if (part.startsWith(name + "=")) {
        return decodeURIComponent(part.slice(name.length + 1));
      }
    }
    return "";
  }

  function loadScriptOnce(src, attrs = {}) {
    if (loadedScripts.has(src)) {
      return loadedScripts.get(src);
    }
    const promise = new Promise((resolve, reject) => {
      const existing = document.querySelector(`script[src="${src}"]`);
      if (existing) {
        resolve();
        return;
      }
      const script = document.createElement("script");
      script.src = src;
      script.async = true;
      script.defer = true;
      Object.entries(attrs).forEach(([k, v]) => script.setAttribute(k, v));
      script.onload = () => resolve();
      script.onerror = () => reject(new Error("No se pudo cargar recurso: " + src));
      document.body.appendChild(script);
    });
    loadedScripts.set(src, promise);
    return promise;
  }

  async function refreshAccessToken() {
    if (refreshPromise) {
      return refreshPromise;
    }
    refreshPromise = fetch("/api/auth/refresh/", {
      method: "POST",
      credentials: "same-origin",
      headers: {
        "Accept": "application/json",
        "X-CSRFToken": getCookie("csrftoken"),
        "X-Requested-With": "fetch",
      },
    })
      .then(async (resp) => {
        if (!resp.ok) {
          accessTokenInMemory = null;
          return false;
        }
        const data = await resp.json();
        accessTokenInMemory = data.access_token || null;
        return true;
      })
      .catch(() => {
        accessTokenInMemory = null;
        return false;
      })
      .finally(() => {
        refreshPromise = null;
      });
    return refreshPromise;
  }

  async function request(url, options = {}) {
    const {
      method = "GET",
      body = null,
      headers = {},
      timeoutMs = 15000,
      retryOn401 = true,
    } = options;

    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), timeoutMs);

    const reqHeaders = new Headers({
      "Accept": "application/json",
      "X-Requested-With": "fetch",
      ...headers,
    });

    if (method !== "GET" && method !== "HEAD" && !reqHeaders.has("X-CSRFToken")) {
      const csrf = getCookie("csrftoken");
      if (csrf) {
        reqHeaders.set("X-CSRFToken", csrf);
      }
    }

    if (accessTokenInMemory && !reqHeaders.has("Authorization")) {
      reqHeaders.set("Authorization", `Bearer ${accessTokenInMemory}`);
    }

    let finalBody = body;
    if (body && !(body instanceof FormData) && typeof body === "object") {
      if (!reqHeaders.has("Content-Type")) {
        reqHeaders.set("Content-Type", "application/json");
      }
      finalBody = JSON.stringify(body);
    }

    try {
      const response = await fetch(url, {
        method,
        body: finalBody,
        headers: reqHeaders,
        credentials: "same-origin",
        signal: controller.signal,
      });

      if (response.status === 401 && retryOn401) {
        const refreshed = await refreshAccessToken();
        if (refreshed) {
          return request(url, { ...options, retryOn401: false });
        }
      }

      const contentType = response.headers.get("content-type") || "";
      const payload = contentType.includes("application/json")
        ? await response.json()
        : await response.text();

      return { ok: response.ok, status: response.status, data: payload };
    } finally {
      clearTimeout(timer);
    }
  }

  function delay(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  async function pollJob(statusUrl, options = {}) {
    const {
      initialDelayMs = 250,
      maxAttempts = 15,
      backoffFactor = 1.4,
      onProgress = null,
    } = options;

    let waitMs = initialDelayMs;
    for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
      const res = await request(statusUrl, { method: "GET" });
      if (!res.ok) {
        throw new Error(
          (res.data && res.data.error) || "Error consultando estado de procesamiento."
        );
      }

      const job = res.data;
      if (typeof onProgress === "function") {
        onProgress(job);
      }

      if (job.status === "completed") {
        return job;
      }
      if (job.status === "failed") {
        throw new Error(job.error || "El procesamiento asincrono fallo.");
      }

      await delay(waitMs);
      waitMs = Math.min(Math.round(waitMs * backoffFactor), 4000);
    }

    throw new Error("Tiempo de espera agotado al consultar el estado de la solicitud.");
  }

  global.MiRefugioApi = {
    request,
    pollJob,
    refreshAccessToken,
    loadScriptOnce,
    setAccessToken(token) {
      accessTokenInMemory = token || null;
    },
  };
})(window);

