# Supabase 配置指南

Flutter 应用现在直接连接到 Supabase 数据库，无需中间 API 服务器。

## 1. 配置 .env 文件（推荐方式）

### 步骤 1：复制环境变量模板
```bash
cp .env.example .env
```

### 步骤 2：编辑 .env 文件
打开 `.env` 文件，填入你的 Supabase 配置：

```env
# Supabase Configuration
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key-here

# App Configuration (Optional)
APP_NAME=GitHub Radar News
APP_VERSION=1.2.1
```

### 步骤 3：运行应用
```bash
flutter run
```

## 2. 替代配置方式

### 方式二：命令行环境变量
```bash
flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
```

### 方式三：直接修改代码（不推荐）
修改 `lib/config/app_config.dart` 中的默认值（不建议用于生产环境）

## 2. 获取 Supabase 凭证

1. 登录 [Supabase Dashboard](https://supabase.com/dashboard)
2. 选择你的项目
3. 进入 **Settings** → **API**
4. 复制以下信息：
   - **Project URL** (用于 `SUPABASE_URL`)
   - **anon/public key** (用于 `SUPABASE_ANON_KEY`)

## 3. 数据库权限设置

### 为匿名用户启用读取权限

由于移动应用使用匿名密钥，需要在 Supabase SQL Editor 中运行以下命令：

```sql
-- 允许匿名用户读取分析数据
ALTER TABLE github_radar_analyses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access" ON github_radar_analyses
    FOR SELECT USING (true);

-- 如果需要读取收集和仓库数据
ALTER TABLE github_radar_collections ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public read access" ON github_radar_collections
    FOR SELECT USING (true);

ALTER TABLE github_radar_repositories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public read access" ON github_radar_repositories
    FOR SELECT USING (true);
```

## 4. 测试连接

运行应用后，检查以下内容：

1. **初始化成功**：应用启动时不应有 Supabase 相关错误
2. **数据加载**：首页应该能够加载分析列表
3. **筛选功能**：语言和类型筛选应该正常工作
4. **搜索功能**：搜索应该能够返回结果

## 5. 故障排除

### 连接失败
- 确认 Supabase URL 和 Key 正确
- 检查网络连接
- 确认 Supabase 项目状态正常

### 数据加载失败
- 确认数据库中有数据
- 检查 RLS 策略是否正确设置
- 查看 Flutter 控制台的错误信息

### 权限错误
```
42501: permission denied for table github_radar_analyses
```
这表示需要设置正确的 RLS 策略（见上述第3步）

## 6. 生产环境建议

1. **使用环境变量**：不要在代码中硬编码凭证
2. **设置适当的 RLS 策略**：根据实际需求限制数据访问
3. **监控 API 使用**：在 Supabase Dashboard 中监控 API 调用量
4. **考虑缓存**：应用已内置基础缓存，减少不必要的 API 调用