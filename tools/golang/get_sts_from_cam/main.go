package main

import (
	"fmt"
	"encoding/json"
	"github.com/tencentcloud/tencentcloud-sdk-go/tencentcloud/common"
)

type CredentialJSON struct {
	TmpSecretId  string `json:"TmpSecretId"`
	TmpSecretKey string `json:"TmpSecretKey"`
	Token     string `json:"Token,omitempty"`
}

func main() {
	provider, err := common.DefaultTkeOIDCRoleArnProvider()
	if err != nil {
		panic(err)
	}

	credential, err := provider.GetCredential()
	if err != nil {
		panic(err)
	}

    credentialJSON := &CredentialJSON {
		TmpSecretId:  credential.GetSecretId(),
		TmpSecretKey: credential.GetSecretKey(),
		Token:     credential.GetToken(),
	}

	jsonData, err := json.Marshal(credentialJSON)
	if err != nil {
		fmt.Println("转换为 JSON 失败:", err)
		return
	}

	fmt.Println(string(jsonData))
}
