import { RepoAnalysis } from "../types/index.js";

export function generateMarkdownReport(analysis: RepoAnalysis): string {
  const repo = analysis.repo;
  const content = analysis.content;

  const markdown = `

${analysis.analysis}


### 项目概述

- **项目名称**: ${repo.full_name}
- **项目地址**: ${repo.html_url}
- **主要语言**: ${repo.language || "未知"}
- **Stars**: ${repo.stargazers_count}
- **Forks**: ${repo.forks_count}
- **开放Issues**: ${repo.open_issues_count}
- **创建时间**: ${new Date(repo.created_at).toLocaleDateString("zh-CN")}
- **最后更新**: ${new Date(repo.pushed_at).toLocaleDateString("zh-CN")}

**项目简介**

${repo.description || "暂无描述"}

**技术栈分析**

**主要编程语言分布**
${Object.entries(content.languages)
  .sort(([, a], [, b]) => b - a)
  .slice(0, 5)
  .map(
    ([lang, bytes]) =>
      `- **${lang}**: ${(
        (bytes / Object.values(content.languages).reduce((a, b) => a + b, 0)) *
        100
      ).toFixed(1)}%`
  )
  .join("\n")}

**关键文件**
${
  content.mainFiles.length > 0
    ? content.mainFiles
        .slice(0, 10)
        .map((file) => `- \`${file}\``)
        .join("\n")
    : "- 暂无关键配置文件"
}
`;

  return markdown;
}
