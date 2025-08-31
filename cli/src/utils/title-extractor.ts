export function extractTitle(content: string): string {
  const lines = content.split('\n');
  
  // Primary method: Look for TITLE: format (most reliable)
  for (const line of lines) {
    const trimmed = line.trim();
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
        return title;
      }
    }
  }
  
  // Secondary method: Look for ### headings
  for (const line of lines) {
    const trimmed = line.trim();
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
        return title;
      }
    }
  }
  
  // Tertiary method: Look for any heading format
  for (const line of lines) {
    const trimmed = line.trim();
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
        return title.substring(0, 100);
      }
    }
  }
  
  // Final fallback: Use first meaningful line
  for (const line of lines) {
    const trimmed = line.trim();
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
        return title;
      }
    }
  }
  
  return 'GitHub项目分析报告';
}