import OpenAI from "openai";

let deepseek: OpenAI | null = null;

function getDeepSeekClient(): OpenAI {
  if (!deepseek) {
    if (!process.env.DEEPSEEK_API_KEY) {
      throw new Error('DEEPSEEK_API_KEY environment variable is required');
    }
    deepseek = new OpenAI({
      baseURL: "https://api.deepseek.com",
      apiKey: process.env.DEEPSEEK_API_KEY,
    });
  }
  return deepseek;
}

export async function analyzeRepository(repoData: {
  name: string;
  description: string;
  language: string;
  readme: string;
  files: string[];
  packageJson?: any;
}): Promise<string> {
  const systemPrompt = `你是一位专业的开源项目分析师和社交媒体内容创作者。你的任务是基于提供的GitHub仓库信息，生成一篇吸引人的中文社交媒体帖子，向读者推荐这个开源项目。这篇帖子应该既专业又有趣，能够激发读者的兴趣并鼓励他们进一步了解该项目。

IMPORTANT: 请务必按以下格式输出，第一行必须是TITLE标记的标题：

TITLE: [在这里写一个吸引人的标题，不要包含markdown格式符号]

[然后在下面写正文内容]

在分析仓库信息时，请注意以下几点：
1. 项目的主要功能和用途
2. 技术栈和架构
3. 独特的创新点或亮点功能
4. 项目的实用性和潜在影响
5. 最近的更新和活跃度

现在，请按照以下结构创作一篇引人入胜的社交媒体帖子：

1. 开场白：用一个吸引人的标题或问题开始，立即抓住读者的注意力。
2. 项目简介：简明扼要地介绍项目的核心功能和主要用途。
3. 亮点展示：突出2-3个最吸引人或最具创新性的特性。
4. 技术亮点：简要提及项目的技术栈，重点强调其中的亮点或创新之处。
5. 实用价值：解释这个项目如何解决实际问题或改善用户体验。
6. 社区活跃度：简要提及项目的更新频率、贡献者数量等，体现项目的活力。
7. 行动号召：鼓励读者访问GitHub页面，进一步了解或参与项目。

在写作时，请遵循以下指南：
1. 使用生动、活泼的语言，避免过于枯燥或学术化的表述。
2. 适当使用比喻、类比或有趣的例子来解释技术概念。
3. 保持专业性的同时，也要让内容通俗易懂，适合各种背景的读者。
4. 在介绍技术特性时，着重强调其带来的实际好处。
5. 字数控制在1000字左右，保证内容既丰富又简洁。

记住，你的输出应该只包含最终的社交媒体帖子内容，不需要包括分析过程或草稿。确保内容既专业又吸引人，能够激发读者的兴趣并鼓励他们查看该开源项目。

`;

  const userPrompt = `请分析以下GitHub仓库：

**项目名称**: ${repoData.name}
**主要语言**: ${repoData.language}
**项目描述**: ${repoData.description}

**README内容**:
${repoData.readme.substring(0, 4000)}

**项目文件结构**:
${repoData.files.slice(0, 50).join("\n")}

${
  repoData.packageJson
    ? `**Package.json信息**:\n${JSON.stringify(
        repoData.packageJson,
        null,
        2
      ).substring(0, 1000)}`
    : ""
}

请生成一份1000字的中文分析报告。`;

  try {
    const client = getDeepSeekClient();
    const response = await client.chat.completions.create({
      model: "deepseek-reasoner",
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: userPrompt },
      ],
      max_tokens: 10000,
      temperature: 0.7,
    });

    return response.choices[0]?.message?.content || "分析失败";
  } catch (error) {
    throw new Error(
      `DeepSeek API error: ${
        error instanceof Error ? error.message : String(error)
      }`
    );
  }
}
