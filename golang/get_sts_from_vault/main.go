package main

import (
    "fmt"
    "github.com/hashicorp/vault/api"
    "log"
    "os"
    "io/ioutil"
)

const (
    credentialsVaultPath = "secret/tencentcloud"     // Vault 中存储 AK/SK 的路径
    stsVaultPath         = "secret/tencentcloud/sts" // Vault 中存储 STS 的路径
    localTmpSecretId     = "/tmp/sts_tmpSecretId"    // 本地文件路径，用于存储 tmpSecretId
    localTmpSecretKey    = "/tmp/sts_tmpSecretKey"   // 本地文件路径，用于存储 tmpSecretKey
    localToken           = "/tmp/sts_token"          // 本地文件路径，用于存储 token
    localAK              = "/tmp/ak"                 // 本地文件路径，用于存储 AK
    localSK              = "/tmp/sk"                 // 本地文件路径，用于存储 SK
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
    if (err != nil) {
        log.Fatalf("Failed to create Vault client: %v", err)
    }
    client.SetToken(vaultToken)

    // 从 Vault 中获取 AK/SK
    credentialsData, err := getCredentialsFromVault(client, credentialsVaultPath)
    if (err != nil) {
        log.Fatalf("Failed to get AK/SK from Vault: %v", err)
    }
    log.Printf("Successfully retrieved AK/SK from Vault: %+v", credentialsData)

    // 将 AK 写入到本地文件
    err = writeToFile(credentialsData["ak"], localAK)
    if (err != nil) {
        log.Fatalf("Failed to write AK to local file: %v", err)
    }
    log.Printf("Successfully wrote AK to %s", localAK)

    // 将 SK 写入到本地文件
    err = writeToFile(credentialsData["sk"], localSK)
    if (err != nil) {
        log.Fatalf("Failed to write SK to local file: %v", err)
    }
    log.Printf("Successfully wrote SK to %s", localSK)

    // 从 Vault 中获取 STS
    stsData, err := getSTSFromVault(client, stsVaultPath)
    if (err != nil) {
        log.Fatalf("Failed to get STS from Vault: %v", err)
    }
    log.Printf("Successfully retrieved STS from Vault: %+v", stsData)

    // 将 tmpSecretId 写入到本地文件
    err = writeToFile(stsData["tmpSecretId"], localTmpSecretId)
    if (err != nil) {
        log.Fatalf("Failed to write tmpSecretId to local file: %v", err)
    }
    log.Printf("Successfully wrote tmpSecretId to %s", localTmpSecretId)

    // 将 tmpSecretKey 写入到本地文件
    err = writeToFile(stsData["tmpSecretKey"], localTmpSecretKey)
    if (err != nil) {
        log.Fatalf("Failed to write tmpSecretKey to local file: %v", err)
    }
    log.Printf("Successfully wrote tmpSecretKey to %s", localTmpSecretKey)

    // 将 token 写入到本地文件
    err = writeToFile(stsData["token"], localToken)
    if (err != nil) {
        log.Fatalf("Failed to write token to local file: %v", err)
    }
    log.Printf("Successfully wrote token to %s", localToken)

    fmt.Println("Credentials and STS retrieval and storage to local files completed successfully.")
}

// 从 Vault 中获取 AK/SK
func getCredentialsFromVault(client *api.Client, path string) (map[string]string, error) {
    secretData, err := client.Logical().Read(path)
    if (err != nil) {
        return nil, fmt.Errorf("failed to read data from %s: %v", path, err)
    }
    if (secretData == nil) {
        return nil, fmt.Errorf("no data found at %s", path)
    }

    credentialsData := make(map[string]string)

    ak, ok := secretData.Data["ak"].(string)
    if (!ok) {
        return nil, fmt.Errorf("ak not found or not a string")
    }
    credentialsData["ak"] = ak

    sk, ok := secretData.Data["sk"].(string)
    if (!ok) {
        return nil, fmt.Errorf("sk not found or not a string")
    }
    credentialsData["sk"] = sk

    return credentialsData, nil
}

// 从 Vault 中获取 STS
func getSTSFromVault(client *api.Client, path string) (map[string]string, error) {
    secretData, err := client.Logical().Read(path)
    if (err != nil) {
        return nil, fmt.Errorf("failed to read data from %s: %v", path, err)
    }
    if (secretData == nil) {
        return nil, fmt.Errorf("no data found at %s", path)
    }

    stsData := make(map[string]string)

    tmpSecretId, ok := secretData.Data["tmpSecretId"].(string)
    if (!ok) {
        return nil, fmt.Errorf("tmpSecretId not found or not a string")
    }
    stsData["tmpSecretId"] = tmpSecretId

    tmpSecretKey, ok := secretData.Data["tmpSecretKey"].(string)
    if (!ok) {
        return nil, fmt.Errorf("tmpSecretKey not found or not a string")
    }
    stsData["tmpSecretKey"] = tmpSecretKey

    token, ok := secretData.Data["token"].(string)
    if (!ok) {
        return nil, fmt.Errorf("token not found or not a string")
    }
    stsData["token"] = token

    return stsData, nil
}

// 将数据写入到本地文件
func writeToFile(data, filePath string) error {
    return ioutil.WriteFile(filePath, []byte(data), 0644)
}

