# 🔐 安全配置指南

## GitHub Secrets 管理

### 必需的 Secrets

为了正常构建和发布应用，需要在 GitHub 仓库中配置以下 secrets：

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `SUPABASE_URL` | Supabase 项目 URL | `https://xxxxx.supabase.co` |
| `SUPABASE_ANON_KEY` | Supabase 匿名密钥 | `eyJhbGciOiJIUzI1NiIs...` |

### 配置步骤

1. **进入仓库设置**
   - 仓库页面 → Settings → Secrets and variables → Actions

2. **添加 Secrets**
   - 点击 "New repository secret"
   - 输入名称和值
   - 点击 "Add secret"

3. **验证配置**
   - 运行 "Test Environment Configuration" 工作流
   - 检查是否所有 secrets 都正确配置

## 🔒 安全最佳实践

### GitHub Secrets

✅ **推荐做法:**
- 使用 GitHub Secrets 存储敏感信息
- 定期轮换 API 密钥
- 使用最小权限原则
- 监控 secrets 的使用情况

❌ **避免做法:**
- 不要在代码中硬编码敏感信息
- 不要在 commit 消息中包含 secrets
- 不要在 Pull Request 中暴露 secrets
- 不要与未授权人员分享 secrets

### Supabase 安全

✅ **推荐配置:**
- 启用 Row Level Security (RLS)
- 使用 anon key 而不是 service key
- 配置适当的数据库策略
- 监控 API 使用情况

❌ **避免配置:**
- 不要使用 service key 在客户端
- 不要禁用所有安全策略
- 不要在公开的地方暴露数据库 URL

## 🚨 安全事件响应

### 如果 Secrets 泄露

1. **立即行动**
   - 撤销泄露的 API 密钥
   - 在 Supabase 控制台中重新生成密钥
   - 更新 GitHub Secrets

2. **评估影响**
   - 检查数据库访问日志
   - 评估潜在的数据泄露
   - 通知相关利益相关者

3. **预防措施**
   - 审查代码变更流程
   - 加强访问控制
   - 实施监控和警报

### 报告安全问题

如果发现安全漏洞，请：

1. **不要**在公开的 issue 中报告
2. 发送邮件到 [security@yourdomain.com]
3. 提供详细的漏洞描述和复现步骤
4. 等待安全团队的响应

## 🔍 安全检查清单

### 部署前检查

- [ ] 所有 secrets 都已正确配置
- [ ] 没有硬编码的敏感信息
- [ ] RLS 策略已启用
- [ ] API 权限设置合理
- [ ] 构建过程不会泄露 secrets

### 定期安全维护

- [ ] 每季度轮换 API 密钥
- [ ] 审查数据库访问日志
- [ ] 更新依赖和安全补丁
- [ ] 检查 GitHub Actions 权限

## 📚 相关文档

- [GitHub Secrets 文档](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Supabase 安全指南](https://supabase.com/docs/guides/auth)
- [Flutter 安全最佳实践](https://flutter.dev/docs/deployment/security)