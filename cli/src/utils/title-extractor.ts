export function extractTitle(content: string): string {
  return extractTitleAndContent(content).title;
}

export function extractTitleAndContent(content: string): { title: string; content: string } {
  const lines = content.split('\n');
  let foundTitleLine = -1;
  let extractedTitle = '';
  
  // Primary method: Look for TITLE: format (most reliable)
  for (let i = 0; i < lines.length; i++) {
    const trimmed = lines[i].trim();
    if (trimmed.startsWith('TITLE:') || trimmed.startsWith('Title:') || trimmed.startsWith('title:')) {
      const title = trimmed
        .replace(/^(TITLE|Title|title):\s*/, '')
        .replace(/\*\*/g, '') // Remove bold
        .replace(/\*/g, '')   // Remove italic
        .replace(/`/g, '')    // Remove code
        .replace(/\[([^\]]+)\]\([^)]+\)/g, '$1') // Remove links, keep text
        .replace(/[🔥🚀✨🌟💡⚡🎯🛠️💻📊🌱📣❤️🔧⭐]/g, '') // Remove emojis
        .trim();
      
      if (title.length > 0) {
        foundTitleLine = i;
        extractedTitle = title;
        break;
      }
    }
  }
  
  // Secondary method: Look for ### headings
  if (foundTitleLine === -1) {
    for (let i = 0; i < lines.length; i++) {
      const trimmed = lines[i].trim();
      if (trimmed.startsWith('### ')) {
        const title = trimmed
          .replace(/^### /, '')
          .replace(/\*\*/g, '')
          .replace(/\*/g, '')
          .replace(/`/g, '')
          .replace(/\[([^\]]+)\]\([^)]+\)/g, '$1')
          .replace(/[🔥🚀✨🌟💡⚡🎯🛠️💻📊🌱📣❤️🔧⭐]/g, '')
          .trim();
        
        if (title.length > 0) {
          foundTitleLine = i;
          extractedTitle = title;
          break;
        }
      }
    }
  }
  
  // Tertiary method: Look for any heading format
  if (foundTitleLine === -1) {
    for (let i = 0; i < lines.length; i++) {
      const trimmed = lines[i].trim();
      if (trimmed.match(/^#+\s+.+/)) {
        const title = trimmed
          .replace(/^#+\s*/, '')
          .replace(/\*\*/g, '')
          .replace(/\*/g, '')
          .replace(/`/g, '')
          .replace(/\[([^\]]+)\]\([^)]+\)/g, '$1')
          .replace(/[🔥🚀✨🌟💡⚡🎯🛠️💻📊🌱📣❤️🔧⭐]/g, '')
          .trim();
        
        if (title.length > 5) {
          foundTitleLine = i;
          extractedTitle = title.substring(0, 100);
          break;
        }
      }
    }
  }
  
  // Final fallback: Use first meaningful line
  if (foundTitleLine === -1) {
    for (let i = 0; i < lines.length; i++) {
      const trimmed = lines[i].trim();
      if (trimmed.length > 10 && 
          !trimmed.startsWith('```') && 
          !trimmed.startsWith('---') &&
          !trimmed.match(/^\s*[-*+]\s/) && // Skip list items
          !trimmed.match(/^\d+\.\s/)) {    // Skip numbered lists
        
        const title = trimmed
          .replace(/\*\*/g, '')
          .replace(/\*/g, '')
          .replace(/`/g, '')
          .replace(/\[([^\]]+)\]\([^)]+\)/g, '$1')
          .replace(/[🔥🚀✨🌟💡⚡🎯🛠️💻📊🌱📣❤️🔧⭐]/g, '')
          .substring(0, 80)
          .trim();
        
        if (title.length > 5) {
          foundTitleLine = i;
          extractedTitle = title;
          break;
        }
      }
    }
  }
  
  // If no title found, use default
  if (foundTitleLine === -1) {
    extractedTitle = 'GitHub项目分析报告';
  }
  
  // Remove the title line from content
  let cleanedContent = content;
  if (foundTitleLine >= 0) {
    const contentLines = [...lines];
    contentLines.splice(foundTitleLine, 1);
    cleanedContent = contentLines.join('\n').trim();
  }
  
  return {
    title: extractedTitle,
    content: cleanedContent
  };
}