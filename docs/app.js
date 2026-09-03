/* Wires config.js values into the page, loads the skill catalog, and
   powers the copy buttons. Plain JS, no dependencies. */
(function () {
  "use strict";
  var cfg = window.HFP_CONFIG || {};

  function byId(id) { return document.getElementById(id); }
  function setText(id, value) { var el = byId(id); if (el && value) el.textContent = value; }
  function setHref(id, value) { var el = byId(id); if (el && value) el.setAttribute("href", value); }

  // ---- config into the page ------------------------------------------------
  document.title = cfg.siteTitle || document.title;
  setText("logo", cfg.logoText);
  setText("site-title", cfg.siteTitle);
  setText("tagline", cfg.tagline);
  setText("description", cfg.description);
  setText("install-cmd", cfg.installCommand);
  setText("marketplace-ref", cfg.claudeMarketplace);
  setHref("installer-link", cfg.installerUrl);
  setHref("installer-link-2", cfg.installerUrl);
  setText("footer-company", cfg.companyName);
  setHref("footer-repo", cfg.repoUrl);
  var support = byId("support-link");
  if (support && cfg.supportContact) {
    support.textContent = cfg.supportContact;
    support.setAttribute("href", "mailto:" + cfg.supportContact);
  }

  // ---- copy buttons --------------------------------------------------------
  function copyText(text, button) {
    function done(ok) {
      if (!ok) { window.prompt("Copy this:", text); return; }
      button.classList.add("copied");
      button.textContent = "Copied ✓";
      var note = button.parentElement.querySelector(".copy-note");
      if (note) note.classList.add("show");
      setTimeout(function () {
        button.classList.remove("copied");
        button.textContent = button.getAttribute("data-label");
      }, 2500);
    }
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(text).then(function () { done(true); },
        function () { done(false); });
    } else { done(false); }
  }

  Array.prototype.forEach.call(document.querySelectorAll("button.copy[data-copy-target]"), function (btn) {
    btn.addEventListener("click", function () {
      var src = byId(btn.getAttribute("data-copy-target"));
      copyText(src ? src.textContent : "", btn);
    });
  });

  var promptBtn = byId("copy-prompt");
  if (promptBtn) {
    promptBtn.addEventListener("click", function () {
      fetch("install-prompt.txt")
        .then(function (r) { if (!r.ok) throw new Error(r.status); return r.text(); })
        .then(function (text) { copyText(text.trim(), promptBtn); })
        .catch(function () {
          copyText("Please install the Hat Fella team skills by reading and then running the installer at " +
            (cfg.installerUrl || "") + " — never use sudo, never delete unrelated files, and list the installed skills when done.", promptBtn);
        });
    });
  }

  // ---- skill catalog -------------------------------------------------------
  var catalogEl = byId("catalog");
  if (catalogEl) {
    fetch("catalog.json")
      .then(function (r) { if (!r.ok) throw new Error(r.status); return r.json(); })
      .then(function (catalog) {
        catalogEl.innerHTML = "";
        (catalog.plugins || []).forEach(function (plugin) {
          var block = document.createElement("div");
          block.className = "plugin-block";
          var h = document.createElement("h3");
          h.textContent = plugin.name;
          var d = document.createElement("p");
          d.className = "plugin-desc";
          d.textContent = plugin.description || "";
          var ul = document.createElement("ul");
          ul.className = "skills";
          (plugin.skills || []).forEach(function (skill) {
            var li = document.createElement("li");
            var strong = document.createElement("strong");
            strong.textContent = skill.name;
            var span = document.createElement("span");
            span.textContent = skill.summary || "";
            li.appendChild(strong);
            li.appendChild(span);
            ul.appendChild(li);
          });
          block.appendChild(h);
          block.appendChild(d);
          block.appendChild(ul);
          catalogEl.appendChild(block);
        });
      })
      .catch(function () {
        catalogEl.innerHTML = "";
        var p = document.createElement("p");
        p.className = "muted";
        p.textContent = "Couldn’t load the live skill list — see the full catalog in the repository: ";
        var a = document.createElement("a");
        a.href = cfg.repoUrl || "#";
        a.textContent = cfg.repo || "GitHub";
        p.appendChild(a);
        catalogEl.appendChild(p);
      });
  }
})();
