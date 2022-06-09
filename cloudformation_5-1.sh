# p153

# デフォルトのVPCを取得
VpcId="$(aws ec2 describe-vpcs --filter "Name=isDefault, Values=true" --query "Vpcs[0].VpcId" --output text)"

# デフォルトのサブネットを取得
SubnetId="$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VpcId" --query "Subnets[0].SubnetId" --output text)"

# ランダムな共有シークレットを作成
# (OpenSSLが動作していない場合はシークレットを独自に作成)
SharedSecret="$(openssl rand -base64 30)"

# ランダムパスワードを作成
# OpenSSLが動作していない場合はランダムシーケンスを独自に作成
Password="$(openssl rand -base64 30)"

# CloudFormationスタックを作成
aws cloudformation create-stack --stack-name vpn --template-url https://s3.amazonaws.com/awsinaction-code2/chapter05/vpn-cloudformation.yaml 
    --parameters ParameterKey=KeyName,ParameterValue=mykey 
    "ParameterKey=VPC,ParameterValue=$VpcId" 
    "ParameterKey=Subnet,ParameterValue=$SubnetId" 
    "ParameterKey=IPSecSharedSecret,ParameterValue=$SharedSecret" 
    ParameterKey=VPNUser,ParameterValue=vpn 
    "ParameterKey=VPNPassword,ParameterValue=$Password"

aws cloudformation wait stack-create-complete --stack-name vpn

aws cloudformation describe-stacks --stack-name vpn --query "Stacks[0].Outputs"