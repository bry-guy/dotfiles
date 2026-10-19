// CI: latest GitHub Actions runs across app repos.
module.exports = {
  title: "ci",
  rows({ store, h }) {
    return {
      cols: [{ h: "REPO", w: 18 }, { h: "WORKFLOW", w: 20 }, { h: "STATUS", w: 12 }, { h: "SHA", w: 8 }, { h: "BRANCH", w: 14 }, { h: "AGE", w: 5 }, { h: "TITLE", w: 60 }],
      rows: store.runs.slice(0, 40).map((r) => {
        const s = r.status === "completed" ? r.conclusion : r.status;
        return { id: `run:${r.id}`, leaf: true, bad: /failure|timed_out|cancelled/.test(s), cells: [r.repo.replace(/^bry-guy\//, ""), r.workflow, h.status(s), r.sha, r.branch, h.age(r.ageMs), r.title] };
      }),
    };
  },
};
