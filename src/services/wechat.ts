import axios from 'axios';
import { promises as fs } from 'fs';
import FormData from 'form-data';

interface WechatConfig {
  appId: string;
  appSecret: string;
}

interface AccessTokenResponse {
  access_token?: string;
  expires_in?: number;
  errcode?: number;
  errmsg?: string;
}

interface Article {
  title: string;
  author?: string;
  digest?: string;
  content: string;
  content_source_url?: string;
  thumb_media_id?: string;
}

interface DraftResponse {
  media_id?: string;
  errcode?: number;
  errmsg?: string;
}

interface MediaUploadResponse {
  type?: string;
  media_id?: string;
  thumb_media_id?: string;
  created_at?: number;
  errcode?: number;
  errmsg?: string;
}

export class WechatPublisher {
  private config: WechatConfig;
  private accessToken: string | null = null;
  private tokenExpiry: number = 0;

  constructor(config: WechatConfig) {
    this.config = config;
  }

  private async getAccessToken(): Promise<string> {
    // Check if token is still valid
    if (this.accessToken && Date.now() < this.tokenExpiry) {
      return this.accessToken;
    }

    try {
      const response = await axios.get<AccessTokenResponse>(
        'https://api.weixin.qq.com/cgi-bin/token',
        {
          params: {
            grant_type: 'client_credential',
            appid: this.config.appId,
            secret: this.config.appSecret,
          },
        }
      );

      // Check for WeChat API error response
      if (response.data.errcode) {
        throw new Error(`WeChat API error ${response.data.errcode}: ${response.data.errmsg}`);
      }

      if (!response.data.access_token) {
        throw new Error(`Failed to get WeChat access token. Response: ${JSON.stringify(response.data)}`);
      }

      this.accessToken = response.data.access_token;
      // Set expiry to 1 hour before actual expiry for safety
      this.tokenExpiry = Date.now() + ((response.data.expires_in || 7200) - 3600) * 1000;

      return this.accessToken;
    } catch (error) {
      if (axios.isAxiosError(error)) {
        throw new Error(
          `WeChat API request failed: ${error.response?.status} ${error.response?.statusText}. Response: ${JSON.stringify(error.response?.data)}`
        );
      }
      throw new Error(
        `WeChat API error: ${
          error instanceof Error ? error.message : String(error)
        }`
      );
    }
  }

  private convertMarkdownToHtml(markdown: string): string {
    // Convert markdown to WeChat-compatible HTML
    return markdown
      // Headers
      .replace(/^### (.*$)/gm, '<h3>$1</h3>')
      .replace(/^## (.*$)/gm, '<h2>$1</h2>')
      .replace(/^# (.*$)/gm, '<h1>$1</h1>')
      // Bold and italic
      .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>')
      .replace(/\*([^*]+)\*/g, '<em>$1</em>')
      // Code blocks
      .replace(/```[\s\S]*?```/g, (match) => {
        const code = match.replace(/```[\w]*\n?/g, '').replace(/```$/g, '');
        return `<pre><code>${code}</code></pre>`;
      })
      // Inline code
      .replace(/`([^`]+)`/g, '<code>$1</code>')
      // Links
      .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2">$1</a>')
      // Line breaks
      .replace(/\n\n/g, '<br><br>')
      .replace(/\n/g, '<br>')
      // Clean up any remaining markdown
      .replace(/^---$/gm, '<hr>');
  }

  async uploadImage(imagePath: string): Promise<string> {
    const accessToken = await this.getAccessToken();
    
    try {
      // Read image file
      const imageBuffer = await fs.readFile(imagePath);
      
      // Create form data
      const formData = new FormData();
      formData.append('media', imageBuffer, {
        filename: 'thumb.png',
        contentType: 'image/png',
      });
      
      const response = await axios.post<MediaUploadResponse>(
        `https://api.weixin.qq.com/cgi-bin/material/add_material?access_token=${accessToken}&type=thumb`,
        formData,
        {
          headers: {
            ...formData.getHeaders(),
          },
        }
      );
      
      // Check for WeChat API error response
      if (response.data.errcode) {
        throw new Error(`WeChat media upload error ${response.data.errcode}: ${response.data.errmsg}`);
      }
      
      const mediaId = response.data.media_id || response.data.thumb_media_id;
      if (!mediaId) {
        throw new Error(`Failed to upload image. Response: ${JSON.stringify(response.data)}`);
      }
      
      return mediaId;
    } catch (error) {
      if (axios.isAxiosError(error)) {
        throw new Error(
          `WeChat media upload failed: ${error.response?.status} ${error.response?.statusText}. Response: ${JSON.stringify(error.response?.data)}`
        );
      }
      throw new Error(
        `Image upload error: ${
          error instanceof Error ? error.message : String(error)
        }`
      );
    }
  }

  async createDraft(article: Article): Promise<string> {
    const accessToken = await this.getAccessToken();

    // Convert markdown content to HTML if needed
    const htmlContent = this.convertMarkdownToHtml(article.content);

    const articleData: any = {
      title: article.title,
      author: article.author || 'GitHub雷达',
      digest: article.digest || article.title.substring(0, 120),
      content: htmlContent,
    };

    // Only add optional fields if they exist
    if (article.content_source_url) {
      articleData.content_source_url = article.content_source_url;
    }
    
    if (article.thumb_media_id) {
      articleData.thumb_media_id = article.thumb_media_id;
    }

    const requestData = {
      articles: [articleData],
    };

    try {
      const response = await axios.post<DraftResponse>(
        `https://api.weixin.qq.com/cgi-bin/draft/add?access_token=${accessToken}`,
        requestData,
        {
          headers: {
            'Content-Type': 'application/json',
          },
        }
      );

      // Check for WeChat API error response
      if (response.data.errcode) {
        throw new Error(`WeChat API error ${response.data.errcode}: ${response.data.errmsg}`);
      }

      if (!response.data.media_id) {
        throw new Error(`Failed to create WeChat draft. Response: ${JSON.stringify(response.data)}`);
      }

      return response.data.media_id;
    } catch (error) {
      if (axios.isAxiosError(error)) {
        throw new Error(
          `WeChat draft API request failed: ${error.response?.status} ${error.response?.statusText}. Response: ${JSON.stringify(error.response?.data)}`
        );
      }
      throw new Error(
        `WeChat draft creation error: ${
          error instanceof Error ? error.message : String(error)
        }`
      );
    }
  }
}

export function initWechatPublisher(): WechatPublisher {
  const appId = process.env.WECHAT_APP_ID;
  const appSecret = process.env.WECHAT_APP_SECRET;

  if (!appId || !appSecret) {
    throw new Error('WECHAT_APP_ID and WECHAT_APP_SECRET environment variables are required');
  }

  return new WechatPublisher({ appId, appSecret });
}