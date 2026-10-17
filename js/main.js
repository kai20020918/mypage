document.getElementById("year").textContent = new Date().getFullYear();

const STATUS_LABEL = {
  live: "公開中",
  "in-progress": "制作中",
  planned: "予定",
};

function renderProjects(projects) {
  const list = document.getElementById("project-list");

  if (!projects || projects.length === 0) {
    list.innerHTML = '<p class="empty">現在準備中です。近日公開予定！</p>';
    return;
  }

  list.innerHTML = projects
    .map((project) => {
      const statusLabel = STATUS_LABEL[project.status] || project.status;
      const tags = (project.tags || [])
        .map((tag) => `<span class="tag">${tag}</span>`)
        .join("");
      const isLive = project.status === "live";
      const linkAttrs = isLive
        ? `href="${project.url}" target="_blank" rel="noopener"`
        : `href="javascript:void(0)" aria-disabled="true" tabindex="-1"`;

      return `
        <article class="project-card">
          <div class="project-card-top">
            <span class="status status-${project.status}">${statusLabel}</span>
          </div>
          <h3>${project.title}</h3>
          <p>${project.description}</p>
          <div class="tag-list">${tags}</div>
          <a class="project-link ${isLive ? "" : "is-disabled"}" ${linkAttrs}>
            ${isLive ? (project.linkLabel || "サイトを見る →") : "公開までお待ちください"}
          </a>
        </article>
      `;
    })
    .join("");
}

renderProjects(typeof PROJECTS !== "undefined" ? PROJECTS : []);

