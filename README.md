# k8s를 이용한 Gitops 기반 CI/CD 자동화
---
### 포함 내용
* 예제 파일
* 스크립트

### 버전 업그레이드 사항
1. Argocd Image Updater가 0.14.0 에서 1.x으로 업그레이드
- 변경사항
  * Annotation으로 애플리케이션에 적용하던 것을 ImageUpdater CRD를 적용하는 방법으로 변경
  * 변경사항을 적용하려면 다음 링크의 문서 참조
     * https://github.com/stepanowon/gitops-k8s/tree/main/8-argocd/image-updater/1.x%20%EB%B2%84%EC%A0%84%EC%9A%A9
- 기존의 버전을 사용하려면
  * helm 을 이용해 설치할 때 다음의 가이드와 같이 직접 변경을 지정합니다.
```
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update argo

helm install argocd-image-updater argo/argocd-image-updater --version 0.14.0 \
--namespace argocd \
--values values-image-updater.yaml
```
