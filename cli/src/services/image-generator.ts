import { createCanvas, registerFont } from 'canvas';
import { promises as fs } from 'fs';
import path from 'path';

export interface ImageConfig {
  width: number;
  height: number;
  backgroundColor: string;
  textColor: string;
  fontSize: number;
  fontFamily: string;
  padding: {
    top: number;
    bottom: number;
    left: number;
    right: number;
  };
}

const defaultConfig: ImageConfig = {
  width: 900,
  height: 500,
  backgroundColor: '#000000',
  textColor: '#ffffff',
  fontSize: 48,
  fontFamily: 'Arial, sans-serif',
  padding: {
    top: 80,
    bottom: 80,
    left: 60,
    right: 60,
  },
};

export async function generateTitleImage(
  title: string,
  outputPath: string,
  config: Partial<ImageConfig> = {}
): Promise<string> {
  const finalConfig = { ...defaultConfig, ...config };
  
  // Create canvas
  const canvas = createCanvas(finalConfig.width, finalConfig.height);
  const ctx = canvas.getContext('2d');
  
  // Fill background
  ctx.fillStyle = finalConfig.backgroundColor;
  ctx.fillRect(0, 0, finalConfig.width, finalConfig.height);
  
  // Set text properties
  ctx.fillStyle = finalConfig.textColor;
  ctx.font = `${finalConfig.fontSize}px ${finalConfig.fontFamily}`;
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  
  // Calculate available text area
  const maxWidth = finalConfig.width - finalConfig.padding.left - finalConfig.padding.right;
  const centerX = finalConfig.width / 2;
  const centerY = finalConfig.height / 2;
  
  // Word wrap function
  function wrapText(text: string, maxWidth: number): string[] {
    const words = text.split('');
    const lines: string[] = [];
    let currentLine = '';
    
    for (const char of words) {
      const testLine = currentLine + char;
      const metrics = ctx.measureText(testLine);
      
      if (metrics.width > maxWidth && currentLine !== '') {
        lines.push(currentLine);
        currentLine = char;
      } else {
        currentLine = testLine;
      }
    }
    
    if (currentLine) {
      lines.push(currentLine);
    }
    
    return lines;
  }
  
  // Wrap text and calculate total height
  const lines = wrapText(title, maxWidth);
  const lineHeight = finalConfig.fontSize * 1.2;
  const totalTextHeight = lines.length * lineHeight;
  
  // Calculate starting Y position to center text vertically
  const startY = centerY - (totalTextHeight / 2) + (lineHeight / 2);
  
  // Draw each line
  lines.forEach((line, index) => {
    const y = startY + (index * lineHeight);
    ctx.fillText(line, centerX, y);
  });
  
  // Save image
  const buffer = canvas.toBuffer('image/png');
  await fs.writeFile(outputPath, buffer);
  
  return outputPath;
}