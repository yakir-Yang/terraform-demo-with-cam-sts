package main

import (
    "fmt"
    "github.com/hashicorp/vault/api"
    "log"
    "os"
    "io/ioutil"
)

const (
    stsVaultPath = "secret/tencentcloud/sts" // Vault 中存储 STS 的路径
    localSTSPath = "/tmp/sts_from_vault.txt" // 本地文件路径
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

    // 从 Vault 中获取 STS
    stsToken, err := getSTSFromVault(client, stsVaultPath)
    if err != nil {
        log.Fatalf("Failed to get STS from Vault: %v", err)
    }
    log.Printf("Successfully retrieved STS from Vault. STS: %s", stsToken)

    // 将 STS 写入到本地文件
    err = writeSTSToFile(stsToken, localSTSPath)
    if err != nil {
        log.Fatalf("Failed to write STS to local file: %v", err)
    }
    log.Printf("Successfully wrote STS to %s", localSTSPath)

    fmt.Println("STS retrieval and storage to local file completed successfully.")
}

// 从 Vault 中获取 STS
func getSTSFromVault(client *api.Client, path string) (string, error) {
    secretData, err := client.Logical().Read(path)
    if err != nil {
        return "", fmt.Errorf("failed to read data from %s: %v", path, err)
    }
    if secretData == nil {
        return "", fmt.Errorf("no data found at %s", path)
    }

    stsToken, ok := secretData.Data["sts"].(string)
    if !ok {
        return "", fmt.Errorf("sts not found or not a string")
    }

    return stsToken, nil
}

// 将 STS 写入到本地文件
func writeSTSToFile(stsToken, filePath string) error {
    return ioutil.WriteFile(filePath, []byte(stsToken), 0644)
}

