package main

import (
    "fmt"
    "github.com/tencentyun/qcloud-cos-sts-sdk/go"
    "github.com/hashicorp/vault/api"
    "log"
    "os"
    "time"
)

const (
    vaultPath   = "secret/tencentcloud"            // Vault 中存储 AK/SK 的路径
    stsVaultPath = "secret/tencentcloud/sts"       // Vault 中存储 STS 的路径
)

func main() {
    vaultAddr := os.Getenv("VAULT_ADDR")
    vaultToken := os.Getenv("VAULT_TOKEN")

    // 创建 Vault 客户端配置
    config := &api.Config{
        Address: vaultAddr,
    }

    // 使用 Vault Token 进行认证
    client, err := api.NewClient(config)
    if err != nil {
        log.Fatalf("Failed to create Vault client: %v", err)
    }
    client.SetToken(vaultToken)

    // 从 Vault 中获取 AK/SK
    ak, sk, err := getCredentials(client, vaultPath)
    if err != nil {
        log.Fatalf("Failed to get AK/SK from Vault: %v", err)
    }
    log.Printf("Successfully retrieved AK/SK from Vault. AK: %s, SK: %s", ak, sk)

    // 使用 AK/SK 换取 STS
    stsToken, err := getSTS(ak, sk)
    if err != nil {
        log.Fatalf("Failed to get STS: %v", err)
    }
    log.Printf("Successfully retrieved STS from Tencent Cloud.\nSTS SessionToken: %s\nTmpSecretID: %s\nTmpSecretKey: %s\nExpiration: %s", stsToken.Credentials.SessionToken, stsToken.Credentials.TmpSecretID, stsToken.Credentials.TmpSecretKey, stsToken.Expiration)

    // 将 STS 写回到 Vault 中
    err = putSTS(client, stsVaultPath, stsToken)
    if err != nil {
        log.Fatalf("Failed to write STS to Vault: %v", err)
    }
    log.Printf("Successfully wrote STS to Vault.")

    fmt.Println("STS acquisition and storage in Vault completed successfully.")
}

// 从 Vault 中获取 AK/SK
func getCredentials(client *api.Client, path string) (string, string, error) {
    secretData, err := client.Logical().Read(path)
    if err != nil {
        return "", "", fmt.Errorf("failed to read data from %s: %v", path, err)
    }
    if secretData == nil {
        return "", "", fmt.Errorf("no data found at %s", path)
    }

    ak, ok := secretData.Data["ak"].(string)
    if !ok {
        return "", "", fmt.Errorf("ak not found or not a string")
    }

    sk, ok := secretData.Data["sk"].(string)
    if !ok {
        return "", "", fmt.Errorf("sk not found or not a string")
    }

    return ak, sk, nil
}

// 使用 AK/SK 换取 STS
func getSTS(ak, sk string) (*sts.CredentialResult, error) {
    c := sts.NewClient(
        ak,
        sk,
        nil,
    )

    opt := &sts.CredentialOptions{
        DurationSeconds: int64(36 * time.Hour.Seconds()),
        Region:          "ap-jakarta",
        Policy: &sts.CredentialPolicy{
            Statement: []sts.CredentialPolicyStatement{
                {
                    Action: []string{"*"},
                    Effect: "allow",
                    Resource: []string{"*"},
                },
            },
        },
    }

    // 请求临时密钥
    res, err := c.GetCredential(opt)
    if err != nil {
        return nil, err
    }

    // 返回 STS Token
    return res, nil
}

// 将 STS 写回到 Vault 中
func putSTS(client *api.Client, path string, sts *sts.CredentialResult) error {
    data := map[string]interface{}{
        "token":        sts.Credentials.SessionToken,
        "tmpSecretId":  sts.Credentials.TmpSecretID,
        "tmpSecretKey": sts.Credentials.TmpSecretKey,
        "timestamp":    time.Now().Format(time.RFC3339),
    }
    _, err := client.Logical().Write(path, data)
    if err != nil {
        return fmt.Errorf("failed to write STS to %s: %v", path, err)
    }

    return nil
}
