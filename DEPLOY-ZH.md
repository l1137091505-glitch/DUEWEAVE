# DUEWEAVE 部署说明

## 1. 上传 GitHub

1. 在 GitHub 新建一个空的公开仓库，例如 `dueweave`。
2. 不要额外创建 README、License 或 `.gitignore`。
3. 解压 `DUEWEAVE-GITHUB-UPLOAD.zip`，把解压后的全部内容上传到仓库根目录。

## 2. 在 Remix 部署合约

1. 打开 Remix，在 `contracts` 文件夹中新建 `DueWeave.sol`。
2. 复制独立文件 `DueWeave.sol` 的全部代码并保存。
3. Solidity Compiler 选择 `0.8.24`，点击 **Compile DueWeave.sol**。
4. 打开 **Deploy & Run Transactions**。
5. Environment 选择 **Browser Extension / MetaMask**，钱包网络切换到 BOT Chain Mainnet。
6. `DueWeave` 构造函数没有参数，直接点击 **Deploy** 并在钱包确认。
7. 部署成功后复制完整合约地址。

BOT Chain 参数：

- Network name：`BOT Chain Mainnet`
- Chain ID：`677`
- Currency symbol：`BOT`
- RPC URL：`https://rpc.botchain.ai`
- Explorer：`https://scan.botchain.ai`

## 3. 在 Vercel 部署网页

1. Vercel → **Add New Project** → 导入刚才的 GitHub 仓库。
2. Framework Preset 选择 **Vite**，Root Directory 保持仓库根目录。
3. 在 Environment Variables 新增：

```text
Key: VITE_DUEWEAVE_ADDRESS
Value: 0x你的完整合约地址
Environment: Production
Type: Config
```

4. 点击 **Deploy**。如果先部署网页、后添加变量，请到 Deployments 重新 **Redeploy**，并且不要使用旧 Build Cache。

## 4. 网页交互顺序

1. 点击 **Choose wallet**，从列表中明确选择 MetaMask 或其他钱包。
2. 钱包会请求切换或添加 BOT Chain。
3. 发行方点击 **Issue invoice**，填写标题、私密发票编号、面值、折扣 BPS 和到期日。
4. 其他钱包在 Ledger 选中发票，填写金额并点击 **Fund invoice**。
5. 达到 Funding price 后，发行方点击 **Draw funds**。
6. 发行方到期支付完整 Face value，点击 **Repay face value**。
7. 每个出资钱包点击 **Claim settlement**，按出资比例领取本息。

## 5. 重要说明

- 私密发票编号只在浏览器中哈希；链上只保存哈希值。
- 合约地址是公开配置，必须选择 Config，不要放钱包私钥。
- 网页绝不会要求助记词或私钥。
- 合约未经专业审计，正式使用前请自行审计，并先使用小额资金测试完整流程。
