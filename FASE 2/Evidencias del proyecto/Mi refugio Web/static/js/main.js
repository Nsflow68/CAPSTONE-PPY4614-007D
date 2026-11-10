const SWEETALERT_CDN = "https://cdn.jsdelivr.net/npm/sweetalert2@11";
const RECAPTCHA_CDN = "https://www.google.com/recaptcha/api.js";

function ensureSwal() {
  if (window.Swal) {
    return Promise.resolve(window.Swal);
  }
  if (!window.MiRefugioApi) {
    return Promise.resolve(null);
  }
  return window.MiRefugioApi.loadScriptOnce(SWEETALERT_CDN).then(() => window.Swal || null);
}

// Scroll suave para enlaces internos
document.addEventListener("click", (e) => {
  const a = e.target.closest('a[href^="/#"], a[href^="#"]');
  if (!a) return;
  const href = a.getAttribute("href");
  if (!href || href === "#") return;
  const id = href.replace("/", "");
  const el = document.querySelector(id);
  if (el) {
    e.preventDefault();
    el.scrollIntoView({ behavior: "smooth", block: "start" });
    history.replaceState(null, "", id);
  }
});

// Auto-cerrar menu movil al hacer clic en un enlace del navbar
document.addEventListener("click", (e) => {
  const navLink = e.target.closest(".navbar .nav-link, .navbar .btn");
  const nav = document.getElementById("mainNavbar");
  if (navLink && nav && nav.classList.contains("show") && window.bootstrap) {
    const bs = window.bootstrap.Collapse.getOrCreateInstance(nav);
    bs.hide();
  }
});

function hydrateLazyImage(img) {
  const realSrc = img.dataset.lazySrc;
  if (!realSrc) return;
  img.src = realSrc;
  img.removeAttribute("data-lazy-src");
}

function initLazyAssetsAndSections() {
  const recaptchaKey = document.body?.dataset?.recaptchaKey || "";
  const contactSection = document.getElementById("contacto");
  let recaptchaLoaded = false;

  const loadRecaptchaIfNeeded = () => {
    if (recaptchaLoaded || !recaptchaKey || !window.MiRefugioApi) return;
    recaptchaLoaded = true;
    window.MiRefugioApi.loadScriptOnce(RECAPTCHA_CDN).catch(() => {});
  };

  const lazySections = document.querySelectorAll("[data-lazy-section]");
  const lazyImages = document.querySelectorAll("img[data-lazy-src]");

  if (!("IntersectionObserver" in window)) {
    lazySections.forEach((sec) => sec.classList.add("is-lazy-hydrated"));
    lazyImages.forEach(hydrateLazyImage);
    loadRecaptchaIfNeeded();
    return;
  }

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        const target = entry.target;
        if (target.tagName === "IMG") {
          hydrateLazyImage(target);
        } else {
          target.classList.remove("is-lazy-pending");
          target.classList.add("is-lazy-hydrated");
          if (contactSection && target === contactSection) {
            loadRecaptchaIfNeeded();
          }
        }
        observer.unobserve(target);
      });
    },
    { rootMargin: "160px 0px" }
  );

  lazySections.forEach((sec) => {
    sec.classList.add("is-lazy-pending");
    observer.observe(sec);
  });
  lazyImages.forEach((img) => observer.observe(img));
}

function initEmergencyDirectoryPagination() {
  const container = document.getElementById("emergencias-directory");
  if (!container || !window.MiRefugioApi) return;

  const grid = document.getElementById("emergencias-grid");
  const pagination = document.getElementById("emergencias-pagination");
  const searchInput = document.getElementById("emergencias-search");
  const counterEl = document.getElementById("emergencias-count");

  const renderCards = (items) => {
    if (!grid) return;
    grid.innerHTML = "";
    if (!items.length) {
      const col = document.createElement("div");
      col.className = "col-12";
      const msg = document.createElement("div");
      msg.className = "alert alert-secondary mb-0";
      msg.textContent = "No se encontraron lineas para tu busqueda.";
      col.appendChild(msg);
      grid.appendChild(col);
      return;
    }

    items.forEach((item) => {
      const col = document.createElement("div");
      col.className = "col-md-4";
      const card = document.createElement("div");
      card.className = "card card-architectural card-accent-left h-100";
      const body = document.createElement("div");
      body.className = "card-body d-flex flex-column";

      const top = document.createElement("div");
      top.className = "d-flex justify-content-between align-items-center mb-2";
      const cat = document.createElement("span");
      cat.className = "badge-rect";
      cat.textContent = item.category;
      const sched = document.createElement("small");
      sched.className = "text-secondary fw-semibold";
      sched.textContent = item.schedule;
      top.appendChild(cat);
      top.appendChild(sched);

      const h5 = document.createElement("h5");
      h5.className = "card-title fw-bold mb-1";
      h5.textContent = item.code;

      const sub = document.createElement("div");
      sub.className = "fw-semibold text-primary mb-2";
      sub.textContent = item.title;

      const p = document.createElement("p");
      p.className = "text-secondary small mb-0 mt-auto";
      p.textContent = item.description;

      body.appendChild(top);
      body.appendChild(h5);
      body.appendChild(sub);
      body.appendChild(p);
      card.appendChild(body);
      col.appendChild(card);
      grid.appendChild(col);
    });
  };

  const renderPagination = (pag) => {
    if (!pagination) return;
    const ul = pagination.querySelector("ul");
    if (!ul) return;
    ul.innerHTML = "";
    if (counterEl && pag) {
      counterEl.textContent = `Pagina ${pag.page} de ${pag.total_pages} (${pag.total_items} registros)`;
    }
    if (!pag || pag.total_pages <= 1) return;

    const addItem = (label, page, disabled, active) => {
      const li = document.createElement("li");
      li.className = `page-item${disabled ? " disabled" : ""}${active ? " active" : ""}`;
      const a = document.createElement("a");
      a.className = "page-link";
      a.href = `?emergencias_page=${page}#emergencias`;
      a.dataset.page = String(page);
      a.textContent = label;
      li.appendChild(a);
      ul.appendChild(li);
    };

    addItem("Anterior", pag.previous_page || 1, !pag.has_previous, false);
    for (let p = 1; p <= pag.total_pages; p += 1) {
      addItem(String(p), p, false, p === pag.page);
    }
    addItem("Siguiente", pag.next_page || pag.total_pages, !pag.has_next, false);
  };

  const loadPage = async (page = 1) => {
    const q = searchInput ? searchInput.value.trim() : "";
    const qs = new URLSearchParams({ page: String(page), page_size: "3" });
    if (q) qs.set("q", q);
    const res = await window.MiRefugioApi.request(`/api/emergencias/?${qs.toString()}`);
    if (!res.ok) return;
    renderCards(res.data.items || []);
    renderPagination(res.data.pagination);
  };

  container.addEventListener("click", (e) => {
    const link = e.target.closest("#emergencias-pagination a.page-link");
    if (!link) return;
    e.preventDefault();
    const targetPage = Number(link.dataset.page || "1");
    if (!Number.isNaN(targetPage) && targetPage >= 1) {
      loadPage(targetPage);
    }
  });

  if (searchInput) {
    let debounceTimer = null;
    searchInput.addEventListener("input", () => {
      clearTimeout(debounceTimer);
      debounceTimer = setTimeout(() => loadPage(1), 220);
    });
  }
}

function initContactAsyncForm() {
  const form = document.getElementById("form_contact");
  const statusBox = document.getElementById("contact-async-status");
  if (!form || !window.MiRefugioApi) return;

  const setStatus = (type, text) => {
    if (!statusBox) return;
    statusBox.className = `alert alert-${type} mt-3 mb-0`;
    statusBox.textContent = text;
    statusBox.classList.remove("d-none");
  };

  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    if (!form.checkValidity()) {
      form.classList.add("was-validated");
      return;
    }

    const submitBtn = form.querySelector('button[type="submit"]');
    if (submitBtn) submitBtn.disabled = true;
    setStatus("info", "Enviando solicitud al servidor...");

    try {
      const formData = new FormData(form);
      const res = await window.MiRefugioApi.request(form.action, {
        method: "POST",
        body: formData,
      });

      if (!res.ok) {
        const errMsg = (res.data && res.data.error) || "No pudimos procesar tu mensaje.";
        setStatus("danger", errMsg);
        return;
      }

      if (res.status === 202 && res.data && res.data.status_url) {
        setStatus("info", "Mensaje en cola. Procesando de forma asincrona...");
        await window.MiRefugioApi.pollJob(res.data.status_url, {
          onProgress: (job) => {
            if (job.status === "processing") {
              setStatus("info", "Procesando y validando solicitud...");
            }
          },
        });
      }

      setStatus("success", "Gracias. Recibimos tu mensaje correctamente.");
      form.reset();
      form.classList.remove("was-validated");
    } catch (err) {
      setStatus("danger", err.message || "Error de conexion al enviar el mensaje.");
    } finally {
      if (submitBtn) submitBtn.disabled = false;
    }
  });
}

function initDonationGuard() {
  const donationForm = document.getElementById("donation-form");
  if (!donationForm || window.AUTHENTICATED) return;

  donationForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    const SwalLib = await ensureSwal();
    const nextUrl = "/accounts/login/?next=" + encodeURIComponent("/#donar");

    if (SwalLib) {
      const result = await SwalLib.fire({
        title: "Debes iniciar sesion",
        text: "Para donar, primero inicia sesion o registrate.",
        icon: "info",
        showCancelButton: true,
        confirmButtonText: "Ir al ingreso",
        cancelButtonText: "Cerrar",
      });
      if (result.isConfirmed) {
        window.location.href = nextUrl;
      }
    } else {
      window.location.href = nextUrl;
    }
  });
}

function initAsyncDonationHistory() {
  const panel = document.getElementById("donation-history-panel");
  if (!panel || !window.MiRefugioApi) return;

  const tbody = document.getElementById("donations-table-body");
  const paginationNav = document.getElementById("donations-pagination");
  const statusFilter = document.getElementById("donations-status-filter");
  const pageSizeSelect = document.getElementById("donations-page-size");
  const liveMsg = document.getElementById("donations-async-feedback");

  const renderRows = (items) => {
    if (!tbody) return;
    tbody.innerHTML = "";
    if (!items.length) {
      const tr = document.createElement("tr");
      const td = document.createElement("td");
      td.colSpan = 7;
      td.className = "text-secondary text-center py-3";
      td.textContent = "No hay donaciones registradas para el filtro actual.";
      tr.appendChild(td);
      tbody.appendChild(tr);
      return;
    }

    items.forEach((d) => {
      const tr = document.createElement("tr");
      const cells = [
        d.created_at,
        d.buy_order,
        `$${d.amount}`,
        d.status,
        d.authorization_code || "-",
        d.payment_type || "-",
      ];
      cells.forEach((val, idx) => {
        const td = document.createElement("td");
        if (idx === 3) td.className = "text-capitalize";
        td.textContent = val;
        tr.appendChild(td);
      });

      const actionTd = document.createElement("td");
      if (d.token_ws) {
        const btn = document.createElement("button");
        btn.type = "button";
        btn.className = "btn btn-outline-mr btn-sm";
        btn.dataset.checkToken = d.token_ws;
        btn.textContent = "Verificar";
        actionTd.appendChild(btn);
      } else {
        actionTd.textContent = "-";
      }
      tr.appendChild(actionTd);
      tbody.appendChild(tr);
    });
  };

  const renderPagination = (pag) => {
    if (!paginationNav) return;
    const ul = paginationNav.querySelector("ul");
    if (!ul) return;
    ul.innerHTML = "";
    if (!pag || pag.total_pages <= 1) return;

    const addItem = (label, page, disabled, active) => {
      const li = document.createElement("li");
      li.className = `page-item${disabled ? " disabled" : ""}${active ? " active" : ""}`;
      const a = document.createElement("a");
      a.className = "page-link";
      a.href = `?page=${page}&page_size=${pag.page_size}`;
      a.dataset.page = String(page);
      a.textContent = label;
      li.appendChild(a);
      ul.appendChild(li);
    };

    addItem("Anterior", pag.previous_page || 1, !pag.has_previous, false);
    for (let p = 1; p <= pag.total_pages; p += 1) {
      addItem(String(p), p, false, p === pag.page);
    }
    addItem("Siguiente", pag.next_page || pag.total_pages, !pag.has_next, false);
  };

  const fetchPage = async (page = 1) => {
    const status = statusFilter ? statusFilter.value : "";
    const pageSize = pageSizeSelect ? pageSizeSelect.value : "10";
    const qs = new URLSearchParams({ page: String(page), page_size: pageSize });
    if (status) qs.set("status", status);

    try {
      const res = await window.MiRefugioApi.request(`/donar/api/historial/?${qs.toString()}`);
      if (!res.ok) return;
      renderRows(res.data.items || []);
      renderPagination(res.data.pagination);
      if (liveMsg) {
        liveMsg.classList.add("d-none");
      }
    } catch (_) {
      /* fallback silencioso */
    }
  };

  panel.addEventListener("click", async (e) => {
    const pageLink = e.target.closest("#donations-pagination a.page-link");
    if (pageLink) {
      e.preventDefault();
      const targetPage = Number(pageLink.dataset.page || "1");
      if (!Number.isNaN(targetPage) && targetPage >= 1) {
        await fetchPage(targetPage);
      }
      return;
    }

    const checkBtn = e.target.closest("button[data-check-token]");
    if (checkBtn) {
      const token = checkBtn.dataset.checkToken;
      checkBtn.disabled = true;
      checkBtn.textContent = "Consultando...";
      try {
        const res = await window.MiRefugioApi.request(
          `/donar/estado/?token=${encodeURIComponent(token)}`
        );
        if (liveMsg) {
          liveMsg.className = res.ok ? "alert alert-info mt-3 mb-0" : "alert alert-warning mt-3 mb-0";
          liveMsg.textContent = res.ok
            ? `Estado transaccion (${res.data.buy_order || ""}): ${res.data.status || "desconocido"}`
            : "No se pudo consultar el estado en este momento.";
          liveMsg.classList.remove("d-none");
        }
      } finally {
        checkBtn.disabled = false;
        checkBtn.textContent = "Verificar";
      }
    }
  });

  if (statusFilter) {
    statusFilter.addEventListener("change", () => fetchPage(1));
  }
  if (pageSizeSelect) {
    pageSizeSelect.addEventListener("change", () => fetchPage(1));
  }
}

document.addEventListener("DOMContentLoaded", () => {
  try {
    const authAttr = document.body?.dataset?.authenticated || null;
    window.AUTHENTICATED = authAttr === "true";
  } catch (_) {
    window.AUTHENTICATED = false;
  }

  const alertEl = document.querySelector(".alert");
  if (alertEl) {
    alertEl.scrollIntoView({ behavior: "smooth", block: "start" });
  }

  initLazyAssetsAndSections();
  initEmergencyDirectoryPagination();
  initContactAsyncForm();
  initDonationGuard();
  initAsyncDonationHistory();

  if (typeof window.showPendingDjangoAlerts === "function") {
    ensureSwal().then((SwalLib) => {
      if (SwalLib) {
        window.showPendingDjangoAlerts(SwalLib);
      }
    });
  }
});
