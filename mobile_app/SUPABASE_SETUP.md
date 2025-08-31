# Supabase 配置指南

Flutter 应用现在直接连接到 Supabase 数据库，无需中间 API 服务器。

## 1. 获取 Supabase 配置

### 方式一：从环境变量（推荐）
```bash
# 在运行应用时设置环境变量
export SUPABASE_URL="your_supabase_project_url"
export SUPABASE_ANON_KEY="your_supabase_anon_key"

# 然后运行应用
flutter run --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

### 方式二：直接修改代码
打开 `lib/config/app_config.dart` 文件，替换默认值：

```dart
static const String supabaseUrl = 'https://your-project-id.supabase.co';
static const String supabaseAnonKey = 'your-anon-key-here';
```

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