# This workflow will do a clean installation of node dependencies, cache/restore them, build the source code and run tests across different versions of node
# For more information see: https://docs.github.com/en/actions/automating-builds-and-tests/building-and-testing-nodejs

name: Node.js CI

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
          
      - name: Configure kubectl
        run: |
          mkdir -p ~/.kube
          echo ${{ secrets.KUBECONFIG }} | base64 --decode > ~/.kube/config
          sudo apt-get update && sudo apt-get install -y kubectl
          kubectl get pod -A
          pwd

      - name: Deploy to EKS
        run: |
          pwd
          kubectl apply -f deployment.yaml
