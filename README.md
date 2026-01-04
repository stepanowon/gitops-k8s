# k8s를 이용한 Gitops 기반 CI/CD 자동화
---
### 포함 내용
* 예제 파일
* 스크립트

# 2026.1 변경 사항
- [Argocd Image updater가 0.14.0에서 1.0으로 업그레이드](#imageupdater)
- [Ingress Nginx Controller 지원종료로 인해 haproxy-ingress-controller로 교체](#haproxy)
---
<a id="imageupdater"></a>
## 1. Argocd Image Updater가 0.14.0 에서 1.x으로 업그레이드
- 변경사항
  * Annotation으로 애플리케이션에 적용하던 것을 ImageUpdater CRD를 적용하는 방법으로 변경
  * 변경사항을 적용하려면 다음 링크의 문서 참조
     * https://github.com/stepanowon/gitops-k8s/tree/main/8-argocd/image-updater/v1.x
- 기존의 버전을 사용하려면
  * helm 을 이용해 설치할 때 다음의 가이드와 같이 직접 버전을 지정합니다.
```
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update argo

helm install argocd-image-updater argo/argocd-image-updater --version 0.14.0 \
--namespace argocd \
--values values-image-updater.yaml
```

<a id="haproxy"></a>
## 2. Ingress Nginx Controller 지원종료로 인해 haproxy-ingress-controller로 교체
- Ingress Nginx Controller를 대신해 사용할 수 있는 Ingress Controller입니다.
- Ingress Nginx Controller는 지원이 종료되었습니다.(관련된 문서를 보려면 [여기](https://nginxstore.com/blog/kubernetes/ingress-nginx-%EC%A7%80%EC%9B%90-%EC%A2%85%EB%A3%8C-%EC%95%88%EB%82%B4-kubernetes-ingress-controller/)를 클릭하세요)

### helm을 이용해 haproxy-iongress-controller 설치
```
# 사전조건 : metalLB가 설치되어 있어야 함. 
# helm repo 추가 후 업데이트
helm repo add haproxytech https://haproxytech.github.io/helm-charts
helm repo update

# namespace 생성
kubectl create namespace haproxy-controller

# ingress-nginx 네임스페이스 ingress-controller 설치
# service 타입을 LB로 설정하고 LB의 IP 주소를 192.168.56.60으로 설정. 이를 위해 metalLB가 미리 설정되어야 함
helm upgrade -i -n haproxy-controller haproxy-ingress haproxytech/kubernetes-ingress \
  --set controller.service.type=LoadBalancer \
  --set controller.service.loadBalancerIP=192.168.56.60 \
  --set controller.ingressClass=haproxy \
  --set controller.ingressClassResource.name=haproxy \
  --set controller.ingressClassResource.enabled=true
```

### nodeapp1.yaml, nodeapp2.yaml은 ingress-nginx-controller에서 사용하던 것과 동일함
```
kubectl apply -f nodeapp1.yaml
kubectl apply -f nodeapp2.yaml
```

### Ingress 작성 (haproxy-ingress-pathrewrite.yaml)
- 작성후 kubectl apply -f haproxy-ingress-pathrewrite.yaml  명령 실행
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: path1-ingress
  annotations:
    haproxy.org/path-rewrite: "/path1/(.*) /\\1"
spec:
  ingressClassName: haproxy
  rules:
  - host: demo.192.168.56.60.nip.io
    http:
      paths:
      - pathType: ImplementationSpecific
        path: /path1/
        backend:
          service:
            name: svc-nodeapp1
            port:
              number: 8080
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: path2-ingress
  annotations:
    haproxy.org/path-rewrite: "/path2/(.*) /\\1"
spec:
  ingressClassName: haproxy
  rules:
  - host: demo.192.168.56.60.nip.io
    http:
      paths:
      - pathType: ImplementationSpecific
        path: /path2/
        backend:
          service:
            name: svc-nodeapp2
            port:
              number: 8080
```

### 기능 테스트
```
curl http://demo.192.168.56.60.nip.io/path1/abc
curl http://demo.192.168.56.60.nip.io/path2/abc
```

### 테스트 완료 후 리소스 정리
```
kubectl delete -f haproxy-ingress-pathrewrite.yaml

kubectl delete -f nodeapp1.yaml
kubectl delete -f nodeapp2.yaml

helm uninstall haproxy-ingress -n haproxy-controller
kubectl delete namespaces haproxy-controller
```

### Ingress에 경로 다시쓰기 기능을 적용하지 않는 경우
- haproxy-ingress.yaml
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: haproxy-ingress
spec:
  ingressClassName: haproxy
  rules:
  - host: demo.192.168.56.60.nip.io
    http:
      paths:
      - pathType: Prefix
        path: /path1
        backend:
          service:
            name: svc-nodeapp1
            port:
              number: 8080
      - pathType: Prefix
        path: /path2
        backend:
          service:
            name: svc-nodeapp2
            port:
              number: 8080
```
---


