# Дипломный практикум в Yandex.Cloud
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
     * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
     * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
     * [Создание тестового приложения](#создание-тестового-приложения)
     * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.
- Следует использовать версию [Terraform](https://www.terraform.io/) не старше 1.5.x .

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)  
3. Создайте VPC с подсетями в разных зонах доступности.
4. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
5. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.


## Решение

Для создания использовал [конфигурацию](https://github.com/zatulik2606/Diplomnew/tree/main/bucket)

**VM'S**

![vm](https://github.com/zatulik2606/Diplomnew/blob/main/screen/vm.jpg)

**Bucket**

![Bucket](https://github.com/zatulik2606/Diplomnew/blob/main/screen/bucket.jpg)

**Network**

![net](https://github.com/zatulik2606/Diplomnew/blob/main/screen/network.jpg)


IP менятся каждый день, т.к. сервисы прерываемые, поэтому прикладываю terraform plan , чтобы было видно, что файл создавался.

<details>

 ~~~
root@debianv:~/diplomnew/bucket# terraform plan
yandex_iam_service_account.sa-terraform: Refreshing state... [id=ajep6shkjhcljpjmb9q0]
yandex_vpc_network.subnet-zones: Refreshing state... [id=enpiij9hsoetrkukb3mf]
yandex_iam_service_account_static_access_key.sa-static-key: Refreshing state... [id=aje0k774qf0rsqh4ef0k]
yandex_resourcemanager_folder_iam_member.terraform-editor: Refreshing state... [id=b1gleu995pjjtd5eficp/editor/serviceAccount:ajep6shkjhcljpjmb9q0]
yandex_storage_bucket.netology-bucketx: Refreshing state... [id=zatulik-netology-bucketz]
yandex_vpc_subnet.subnet-zones[2]: Refreshing state... [id=fl8n2fractdsdbjv18s5]
yandex_vpc_subnet.subnet-zones[1]: Refreshing state... [id=e2l64ngiguf9jh79uk4n]
yandex_vpc_subnet.subnet-zones[0]: Refreshing state... [id=e9bcv351qujsgca8ib8h]
yandex_compute_instance.cluster-k8s[0]: Refreshing state... [id=fhmcmhlj93vbm34milnm]
yandex_compute_instance.cluster-k8s[1]: Refreshing state... [id=epdiqpsb1isceubvipp8]
yandex_compute_instance.cluster-k8s[2]: Refreshing state... [id=fv4hdn1rv94st83oafmj]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # yandex_storage_bucket.netology-bucketx will be updated in-place
  ~ resource "yandex_storage_bucket" "netology-bucketx" {
        id                    = "zatulik-netology-bucketz"
        tags                  = {}
        # (9 unchanged attributes hidden)

      - logging {
          - target_bucket = "zatulik-netology-bucketz" -> null
        }

        # (2 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

Changes to Outputs:
  ~ external_ip_address_nodes = {
      ~ node-0 = "51.250.85.78" -> "158.160.114.165"
      ~ node-1 = "158.160.70.60" -> "158.160.65.118"
      ~ node-2 = "158.160.134.58" -> "158.160.157.214"
~~~
</details>

---
### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.


## Решение

Для создания использовал [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)

После установки проверяю версию

~~~
ubuntu@node0:~$ sudo kubectl version
Client Version: v1.29.3
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3
Server Version: v1.29.3

~~~

Проверяю nodes


~~~
ubuntu@node0:~$ sudo kubectl get nodes
NAME    STATUS   ROLES           AGE   VERSION
node0   Ready    control-plane   89m   v1.29.3
node1   Ready    <none>          89m   v1.29.3
node2   Ready    <none>          89m   v1.29.3

~~~

Проверяю файл конфигурации.

<details>

~~~
ubuntu@node0:~$ cat ~/.kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJUDVXb3BkMWZCejR3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TkRBME1qVXhOelU0TlROYUZ3MHpOREEwTWpNeE9EQXpOVE5hTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURtZmYvYjZnVkgvb1NYd0gwakdSN1JCRmpIOEVIdmExY2EvRXQvdnM0a0RLMUU0cWxlU3oydzJkN3oKSmd3Uk81NTNmbGxZRnpjM0J3UDZXS2FtdnRRRDcrL3k4RDRLcFBYMVNEMnJoZUxPRmwvWlo4bFZLWVVuS1FqeApjamZ6WG4rcGV6aUJZVEk3N3BOeTdUczFLeDZIM21WbWF1dXNhYjJkUzlobGZ2NkxZb0NPb0Q3TVkvUjdxcUExCnBhRW44bVY1a2ZRdnFlcHZiajlKOWtuZ1dLOUJlZTg1T3hLWDFrWHpRMExaN2ZkbGIveTJUa280M1g5dHdYUTkKcEh4dExVWW5XcmdxUmJLd1BIMjRLbHNGTWJhTzlqYlFKa1J0ZXNUdUtwNmwwdkpWdTVpM0dhN21mcDQ5amNNMQpDOWdEd0xGK29LQVBVNXVvS21XRkdJT255bjN4QWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJUajJUOTZGWTdUQnRnczgwb2lYanNjVEJzMFBqQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQjQwMGJYNG1EdQp0YUYrbFI0dWlQclRIaFcwSlRUM0tvVFFVaWQ1cnpsZUF0L0Yyc2dLcmNCTnk1bzlQWGtNNXRqZFhEQmxnZE5FCmx6eEpSbUN2a2p5b2FTdGZnOXArZEJMdmpiUHZnaTh0dHF1ak9YWVE3REszWUYzdkRXaGZtYkVKR3A3VEVGOXcKY1Vyd3FsdElkL3pkemo4S0VJK3FIYU5WeG1WQ05JRy9tb1lXV2tMN3BDUDRaYUpoY0dhYThmRnhOTG0zL3JuUQorRjRsTnU3aHk4MEVXQk1IWkc1ZFIwdzFxcTd3NnBLODVrQmI3SnNxbURDNkZabnFrTHMyWWE0VDRhak51dGdTCkdUUWhEN2ZNdU45T0plV0dEUDJxcTBGTTNvSHZwdHErY3R5SGVKK2hQdmZaVXVPZGZIUmZqS0p1cVEwU1NQMzMKUTVTdHVlL09mNTdjCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://127.0.0.1:6443
  name: cluster.local
contexts:
- context:
    cluster: cluster.local
    user: kubernetes-admin
  name: kubernetes-admin@cluster.local
current-context: kubernetes-admin@cluster.local
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURLVENDQWhHZ0F3SUJBZ0lJWHFDcFpmSjBINkV3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TkRBME1qVXhOelU0TlROYUZ3MHlOVEEwTWpVeE9EQXpOVFJhTUR3eApIekFkQmdOVkJBb1RGbXQxWW1WaFpHMDZZMngxYzNSbGNpMWhaRzFwYm5NeEdUQVhCZ05WQkFNVEVHdDFZbVZ5CmJtVjBaWE10WVdSdGFXNHdnZ0VpTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElCRHdBd2dnRUtBb0lCQVFER0NlMS8KaVVSWHFVSU54aDhYemtMSmRuL1R4SGRwcERBRGtMb2RjZ2gzSG4wVXFwdis0Vm1pVWRLd3FuYTdsWVNIeGJNLwpwUGxCNFA5ZXFLcDVxd20veWcwdDk5SnNiaXA2L3lrNndpNkNQSm5PbldmTHBkeHY1cXlaTE1hVXF5WEViTVdvClBTUUcvK1ZIWUlFT2R2UDN6VmRydEZpMG1Td1V3U0MxYllxVStOTzcvbER4TnV6aVRHUmJPMXNOalNiN2VIVGIKV05jNmt4dEw4UFNxVUh2NjZ1czRHT3VwV0JCQUFoKzVBeVZ3QnB5am1zTmxrK2g2Q0VTZW9BcDV1cmRXa0xXMgpqUFB2WnFXeUZVVElGdk5SYnJTZlRteDdFQlQ0bllBb084eXRhZWRSVmMveXpDQTJiQTBFRTdUVUo2bnJ4QWVQCll3NktiNnQySkxaaGx5RnpBZ01CQUFHalZqQlVNQTRHQTFVZER3RUIvd1FFQXdJRm9EQVRCZ05WSFNVRUREQUsKQmdnckJnRUZCUWNEQWpBTUJnTlZIUk1CQWY4RUFqQUFNQjhHQTFVZEl3UVlNQmFBRk9QWlAzb1ZqdE1HMkN6egpTaUplT3h4TUd6UStNQTBHQ1NxR1NJYjNEUUVCQ3dVQUE0SUJBUUJ3bXJRRlNsUDhhYjRrVTZNbFZHMG1ZaVFIClRSaS96YUpFeDBaMVg1VGIxb3hVSXg5ZFFlSzY4UXl3Y0hSTmNjY0krTFFJalVIWitVUXMwemZqOWdvVjFyOFgKUjJ5blB1RTMwN1hoMGtwcXRyZnc4LzcwWU1YN3ptQmNRMlBkYkU5am0wRDV2VG11d2gwMmJYVzNpZ1pwNjZCWgpiaWl1K0ZtdnRKSTFpUlpEVE83SUxaTE9TUnZodytzSW5aMzdDVUdOTHlvdDNJY2FkK0FiMVNWNmIyeXI1Q2xrCmE0aWNGUkVTY0NxU2hjd0NRbmpKU0R2VXJjVUhYYzRoRVJWR3prZXh0anR5RFdQQ2tRbUU1L3REOXpsMDRMbzkKQ1FSY0FzbEhMSWpVeUdVaWJuUXpxcVhIcXFqVXZJTEd1N3J3TG1UbEw4WTZEaVlSbnk0cUw3UkFFWU56Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb3dJQkFBS0NBUUVBeGdudGY0bEVWNmxDRGNZZkY4NUN5WFovMDhSM2FhUXdBNUM2SFhJSWR4NTlGS3FiCi91RlpvbEhTc0twMnU1V0VoOFd6UDZUNVFlRC9YcWlxZWFzSnY4b05MZmZTYkc0cWV2OHBPc0l1Z2p5WnpwMW4KeTZYY2IrYXNtU3pHbEtzbHhHekZxRDBrQnYvbFIyQ0JEbmJ6OTgxWGE3Ull0SmtzRk1FZ3RXMktsUGpUdS81UQo4VGJzNGt4a1d6dGJEWTBtKzNoMDIxalhPcE1iUy9EMHFsQjcrdXJyT0JqcnFWZ1FRQUlmdVFNbGNBYWNvNXJEClpaUG9lZ2hFbnFBS2VicTNWcEMxdG96ejcyYWxzaFZFeUJielVXNjBuMDVzZXhBVStKMkFLRHZNcldublVWWFAKOHN3Z05td05CQk8wMUNlcDY4UUhqMk1PaW0rcmRpUzJZWmNoY3dJREFRQUJBb0lCQURQdXNvczVVZVN6REJGVQpuUjYvQmlDU3BKN0I3SmFWYWNubGtBamN1SCtVVFRTNE1NUThFQ2RTMGE5bVpGQjR1eEpuczhQQzNXSjdRRHh3CmVwUUJXRU1sRnlPdzAwdC84RC9rM2NqODF2bHNMdUZSd2NCVHRHVGIxdk1zSEw4cnluR2lISXNyeldEUWhpMmIKanZ4ZUVVZ3dYdlp0aXIyQlZWL3o3VUhtZ2VyaWh3MGFBNFVSbE1aWDZlV2F6OW5CUVJnZFNSWWp5WlMwWEl1bAo4ZVdVY3FLeEs2SnZpdUVZUUpQaE9GZld1d0RrYWQxSWMwU3FVN0QvYVU0QXFMWlJSOEZQQUpVWC9IRjVxaDJvCndudHN5RUJmbGN0a3hKRThsMFdHbmxXSFZqWGdFbnBYR2JrS0xlMUNLQUVacW9WaStRYjZzVE81QzA1Q05TZGcKWGhCN0IxRUNnWUVBOVZGa2ZSMDA4ZHJCSUNhYnRJeDVNeWxERUcwVXN2YjJLUGJPVC9SQ0l3UGFvMXpIOFhOdQpZbHZLdFMwMGZ6UXgwOHcyRUNGYnJLRGQ0RERPNWw3RENVMW45ZUIvSUVnalk1ZnU0YjVDMFRHUEZzZmJLU05jCnhsN3UxM21KUlVRcXFORUNEMGZSSFo3UG1TVEtEVGxqMFlQejVlNWFzV0J4YkZPQUxJMnNzQzBDZ1lFQXpxbUIKVExUcktaaFNSWGJIeWJXazBSZnFXK09hUmdwaVUrWnpydjhTQWpsNDM5d2FhTUlRM0Rjd2VLNXdZRHFXci9oSApXT1JFUTZudDZTRkF1dVYyTkQwVEp1bjU1eXpKbUZSUjhMSDBRT2x5VHZCSnc0bEJySWdpOTc5VGQ3RmVWMmFuCkt4eU1RcEE0dUpVN0FMbkJnL0pnMjFDQWh6MkRrcnlzUTBTNGZCOENnWUJuZzY3SmRIZVF6bVBMc3o3a2twbloKMHNGdnZ2ZUxCTmFlTm5hY0drK0dBdXhSSHFkbjVQTmhJYWFKaU1lc0hWUWhNUHhuRmd4ZTdZcHlQV1l3b3kvZApUd0pkS0J1OGZYUWhaRXp5aUp3ZE5iSlJSSWZmOWdJQjJyRWh6ekR6UDI1WXljajZ0YTB4dUgrVStZY2d5V1NyClZlaW16MHNKcWM1eWpWRjZlMVd4Q1FLQmdBRklqalFDdjU4ZmdndEtaSTA5SW92bDRSKzI5eU5PTnpRY0wwVzcKOGNtdnY2OXNONEhGQ3NQRFYvcTM0cHpHWUY4eFpJZ0p5dDY4dEd5Sk4xU3h6aDBlNy9xQzQzbHJEc2x5Wkp2aApEd3BFS09DU24zS21iSkQ4dTNMY2JsRkUrYmdEUERDSldkbWorYVl6end6L0dsT09jc21KNDNKemtGaWQ4VmZ0Cm1sT3pBb0dCQU02b3czek5tM0dLQkp0a0tSWm9PSVRLRUMxWi9aTGJoRDNJSkozcUhVMmFVTTFMS2hRODBtc2wKY3NBQzllMmVHc09PdXNUWEZpdy9sRnpUM2ppb2pEOVZyU01zWi83dkxoSUFGNFBHaWlpajFxOGhZM3VCWnVDSwpDNFFxV0VxQVY3K0t6cVovTFdaUXlQVTllUndnYW9WRmdlUGdnUEg2dmhDdlo1dGFBZklUCi0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==

~~~
</details>


Проверяю pods

~~~
ubuntu@node0:~$ sudo kubectl get pods --all-namespaces
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-6c7b7dc5d8-lq7bt   1/1     Running   0          98m
kube-system   calico-node-4n449                          1/1     Running   0          99m
kube-system   calico-node-f8jk4                          1/1     Running   0          99m
kube-system   calico-node-gsmmc                          1/1     Running   0          99m
kube-system   coredns-69db55dd76-4wsgb                   1/1     Running   0          98m
kube-system   coredns-69db55dd76-cx7g4                   1/1     Running   0          98m
kube-system   dns-autoscaler-6f4b597d8c-4hthw            1/1     Running   0          98m
kube-system   kube-apiserver-node0                       1/1     Running   1          101m
kube-system   kube-controller-manager-node0              1/1     Running   2          101m
kube-system   kube-proxy-hhk7d                           1/1     Running   0          100m
kube-system   kube-proxy-mgwsg                           1/1     Running   0          100m
kube-system   kube-proxy-n6wrp                           1/1     Running   0          100m
kube-system   kube-scheduler-node0                       1/1     Running   1          101m
kube-system   nginx-proxy-node1                          1/1     Running   0          100m
kube-system   nginx-proxy-node2                          1/1     Running   0          100m
kube-system   nodelocaldns-j779q                         1/1     Running   0          98m
kube-system   nodelocaldns-p9jcw                         1/1     Running   0          98m
kube-system   nodelocaldns-xwcfg                         1/1     Running   0          98m


~~~


Можно скопировать конфу  к себе и проверить.

~~~
root@debianv:~/diplomnew/kubespray# scp -o 'StrictHostKeyChecking no' ubuntu@158.160.114.165:/home/ubuntu/.kube/config $HOME/.kube/config
config                                                                                                                      100% 5661   163.5KB/s   00:00    
root@debianv:~/diplomnew/kubespray# sed -i 's/127.0.0.1/158.160.114.165/g' $HOME/.kube/config
root@debianv:~/diplomnew/kubespray# kubectl get pods --all-namespaces
NAMESPACE     NAME                                                     READY   STATUS    RESTARTS       AGE
default       myapp-myapp-6cb564796-xmw87                              1/1     Running   1 (120m ago)   45h
kube-system   calico-kube-controllers-6c7b7dc5d8-lq7bt                 1/1     Running   2 (120m ago)   7d14h
kube-system   calico-node-4n449                                        1/1     Running   2 (120m ago)   7d14h
kube-system   calico-node-f8jk4                                        1/1     Running   2 (120m ago)   7d14h
kube-system   calico-node-gsmmc                                        1/1     Running   2 (120m ago)   7d14h
kube-system   coredns-69db55dd76-cx7g4                                 1/1     Running   2 (120m ago)   7d14h
kube-system   coredns-69db55dd76-jjsnq                                 1/1     Running   0              17m
kube-system   dns-autoscaler-6f4b597d8c-cdcfk                          1/1     Running   0              17m
kube-system   kube-apiserver-node0                                     1/1     Running   3 (120m ago)   7d14h
kube-system   kube-controller-manager-node0                            1/1     Running   4 (120m ago)   7d14h
kube-system   kube-proxy-5j7t2                                         1/1     Running   0              4m18s
kube-system   kube-proxy-f8rrx                                         1/1     Running   0              4m18s
kube-system   kube-proxy-ff4q8                                         1/1     Running   0              4m18s
kube-system   kube-scheduler-node0                                     1/1     Running   3 (120m ago)   7d14h
kube-system   nginx-proxy-node1                                        1/1     Running   2 (120m ago)   7d14h
kube-system   nginx-proxy-node2                                        1/1     Running   2 (120m ago)   7d14h
kube-system   nodelocaldns-j779q                                       1/1     Running   3 (120m ago)   7d14h
kube-system   nodelocaldns-p9jcw                                       1/1     Running   4 (119m ago)   7d14h
kube-system   nodelocaldns-xwcfg                                       1/1     Running   3 (119m ago)   7d14h
monitoring    alertmanager-stable-kube-prometheus-sta-alertmanager-0   2/2     Running   4 (120m ago)   6d23h
monitoring    prometheus-stable-kube-prometheus-sta-prometheus-0       2/2     Running   4 (120m ago)   6d23h
monitoring    stable-grafana-776646478d-2lmc5                          3/3     Running   7 (120m ago)   6d23h
monitoring    stable-kube-prometheus-sta-operator-6cc67445fb-ctkrp     1/1     Running   2 (120m ago)   6d23h
monitoring    stable-kube-state-metrics-75bf56f4c8-6qjjw               1/1     Running   3 (118m ago)   6d23h
monitoring    stable-prometheus-node-exporter-9626j                    1/1     Running   2 (120m ago)   6d23h
monitoring    stable-prometheus-node-exporter-v9w5k                    1/1     Running   2 (120m ago)   6d23h
monitoring    stable-prometheus-node-exporter-wn7wl                    1/1     Running   2 (120m ago)   6d23h


~~~

---
### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.


## Решение

В данной [папке](https://github.com/zatulik2606/Diplomnew/tree/main/myapp) находится конфигурация


Это [Dockerfile](https://github.com/zatulik2606/Diplomnew/blob/main/myapp/Dockerfile)


Это [Образ в Docker.io](https://hub.docker.com/r/zatulik2606/myapp/tags)

---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:
1. Воспользовать пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). При желании можете собрать все эти приложения отдельно.
2. Для организации конфигурации использовать [qbec](https://qbec.io/), основанный на [jsonnet](https://jsonnet.org/). Обратите внимание на имеющиеся функции для интеграции helm конфигов и [helm charts](https://helm.sh/)
3. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ к тестовому приложению.


## Решение


Устанавливаю helm


~~~
ubuntu@node0:~$ $curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
-fsSL: command not found
ubuntu@node0:~$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
ubuntu@node0:~$ chmod 700 get_helm.sh
ubuntu@node0:~$ ./get_helm.sh
[WARNING] Could not find git. It is required for plugin installation.
Downloading https://get.helm.sh/helm-v3.14.4-linux-amd64.tar.gz
Verifying checksum... Done.
Preparing to install helm into /usr/local/bin
helm installed into /usr/local/bin/helm

~~~

Скачиваю репо

~~~
ubuntu@node0:~$ kubectl create namespace monitoring
namespace/monitoring created
ubuntu@node0:~$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
"prometheus-community" has been added to your repositories
ubuntu@node0:~$ helm install stable prometheus-community/kube-prometheus-stack --namespace=monitoring
NAME: stable
LAST DEPLOYED: Fri Apr 26 08:34:42 2024
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=stable"

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.

~~~

Для подключения к серверу настрою сервисы prometheus и grafana изменив на  NodePort


~~~
kubectl edit svc stable-kube-prometheus-sta-prometheus -n monitoring

kubectl edit svc stable-grafana -n monitoring


ubuntu@node0:~$ kubectl get svc -n monitoring
NAME                                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                         AGE
alertmanager-operated                     ClusterIP   None            <none>        9093/TCP,9094/TCP,9094/UDP      9m17s
prometheus-operated                       ClusterIP   None            <none>        9090/TCP                        9m17s
stable-grafana                            NodePort    10.233.63.222   <none>        80:32108/TCP                    9m27s
stable-kube-prometheus-sta-alertmanager   ClusterIP   10.233.7.12     <none>        9093/TCP,8080/TCP               9m27s
stable-kube-prometheus-sta-operator       ClusterIP   10.233.41.148   <none>        443/TCP                         9m27s
stable-kube-prometheus-sta-prometheus     NodePort    10.233.10.254   <none>        9090:31097/TCP,8080:31485/TCP   9m27s
stable-kube-state-metrics                 ClusterIP   10.233.60.38    <none>        8080/TCP                        9m27s
stable-prometheus-node-exporter           ClusterIP   10.233.62.37    <none>        9100/TCP                        9m27s

~~~

Для подключения используем

UserName: admin Password: prom-operator

**Grafana**

![Grafana](https://github.com/zatulik2606/Diplomnew/blob/main/screen/grafana.jpg)




**Prometheus**

![Prometheus](https://github.com/zatulik2606/Diplomnew/blob/main/screen/prometheus.jpg)



Папка для конфигурации helm тестового приложения в  git находится [тут](https://github.com/zatulik2606/Diplomnew/tree/main/myapp/myapp-helm)



Поменял конфиги через helm и установил приложение.


~~~
ubuntu@node0:~/myapp$ helm install myapp ./
NAME: myapp
LAST DEPLOYED: Wed May  1 10:56:25 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None

~~~

Проверяю Pod и Service.


~~~

ubuntu@node0:~/myapp$ kubectl get pod -o wide
NAME                          READY   STATUS    RESTARTS   AGE    IP               NODE    NOMINATED NODE   READINESS GATES
myapp-myapp-6cb564796-xmw87   1/1     Running   0          110s   10.233.102.155   node1   <none>           <none>
ubuntu@node0:~/myapp$ kubectl get svc
NAME          TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
kubernetes    ClusterIP   10.233.0.1     <none>        443/TCP        5d17h
myapp-myapp   NodePort    10.233.54.38   <none>        80:30880/TCP   2m1s

~~~


Проверяю доступ по http.


![myappweb](https://github.com/zatulik2606/Diplomnew/blob/main/screen/myappweb.jpg)




---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.


## Решение

Для решения была выбрана CI CD на основе gitlab.

Для удобства запуска собрал образ [там же](https://gitlab.com/zatulik2606/Diplomnew/container_registry/6346310) 

Перенес файл с конфигами в репо [Gitlab](https://gitlab.com/zatulik2606/Diplomnew) 

Установил кластер.

~~~
root@debianv:~/diplomnew/CICD# helm repo add gitlab https://charts.gitlab.io
helm repo update
helm upgrade --install gitlab-agent gitlab/gitlab-agent \
    --namespace gitlab-agent-gitlab-agent \
    --create-namespace \
    --set image.tag=v17.0.0-rc3 \
    --set config.token=glagent-RqZFRBk_2uuVFsc7YJGR8kTwsqX2wVmRyu2EW-Us8y3JUfW3sQ \
    --set config.kasAddress=wss://kas.gitlab.com
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /root/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /root/.kube/config
"gitlab" already exists with the same configuration, skipping
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /root/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /root/.kube/config
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "runatlantis" chart repository
...Successfully got an update from the "gitlab" chart repository
Update Complete. ⎈Happy Helming!⎈
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /root/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /root/.kube/config
Release "gitlab-agent" does not exist. Installing it now.
NAME: gitlab-agent
LAST DEPLOYED: Fri May  3 15:48:58 2024
NAMESPACE: gitlab-agent-gitlab-agent
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Thank you for installing gitlab-agent.

Your release is named gitlab-agent.

## Changelog

### 1.17.0

- The default replica count has been increased from `1` to `2` to allow a zero-downtime upgrade experience.
  You may use `--set replicas=1` to restore the old default behavior.


~~~


Создал файл для подключения runner.

~~~

root@debianv:~/diplomnew/CICD# cat runner-chart-values.yaml
# The GitLab Server URL (with protocol) that you want to register the runner against
# ref: https://docs.gitlab.com/runner/commands/index.html#gitlab-runner-register
#
gitlabUrl: https://gitlab.com/

# The registration token for adding new runners to the GitLab server
# Retrieve this value from your GitLab instance
# For more info: https://docs.gitlab.com/ee/ci/runners/index.html
#
runnerRegistrationToken: "glrt-oSkgV4zVSAUM9L9EiKKp"

# For RBAC support:
rbac:
    create: true

# Run all containers with the privileged flag enabled
# This flag allows the docker:dind image to run if you need to run Docker commands
# Read the docs before turning this on:
# https://docs.gitlab.com/runner/executors/kubernetes.html#using-dockerdind
runners:
    privileged: true
    executor: kubernetes

~~~


Сгенерировал манифест и запустил его. 

Файлы с манифестами в [этой папке](https://github.com/zatulik2606/Diplomnew/tree/main/CICD)

~~~
root@debianv:~/diplomnew/CICD# helm template --namespace gitlab gitlab-runner -f runner-chart-values.yaml gitlab/gitlab-runner > runner-manifest.yaml


root@debianv:~/diplomnew/CICD# kubectl apply -f runner-manifest.yaml
serviceaccount/gitlab-runner created
secret/gitlab-runner created
configmap/gitlab-runner created
role.rbac.authorization.k8s.io/gitlab-runner created
rolebinding.rbac.authorization.k8s.io/gitlab-runner created
deployment.apps/gitlab-runner created

~~~

После создал файл gitlab-ci.yml .

~~~

stages:
  - build
  - deploy

variables:
  IMAGE_TAG: $CI_COMMIT_SHORT_SHA
  K8S_NAMESPACE: default
  K8S_DEPLOYMENT_NAME: web-app-deployment
  K8S_SERVICE_NAME: web-app-service
  
build:  
  stage: build
  image:
    name: gcr.io/kaniko-project/executor:v1.9.0-debug
    entrypoint: [""]
  script:
    - /kaniko/executor
      --context "${CI_PROJECT_DIR}"
      --dockerfile "${CI_PROJECT_DIR}/Dockerfile"
      --destination "${CI_REGISTRY_IMAGE}:${IMAGE_TAG}"
  only:
    - main

deploy:
  image:
    name: bitnami/kubectl:latest
    entrypoint: ['']
  stage: deploy
  script:
    - kubectl config get-contexts
    - kubectl config use-context zatulik2606/Diplomnew:gitlab-agent
    - |
      kubectl apply -f - <<EOF
      ---
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: $K8S_DEPLOYMENT_NAME
        namespace: $K8S_NAMESPACE
      spec:
        replicas: 3
        selector:
          matchLabels:
            app: $K8S_DEPLOYMENT_NAME
        template:
          metadata:
            labels:
              app: $K8S_DEPLOYMENT_NAME
          spec:
            containers:
              - name: $K8S_DEPLOYMENT_NAME
                image: $CI_REGISTRY_IMAGE:$IMAGE_TAG
                ports:
                  - containerPort: 80
      ---
      apiVersion: v1
      kind: Service
      metadata:
        name: $K8S_SERVICE_NAME
        namespace: $K8S_NAMESPACE
      spec:
        selector:
          app: $K8S_DEPLOYMENT_NAME
        ports:
          - name: http
            protocol: TCP
            port: 80
            targetPort: 80
            nodePort: 30000
        type: NodePort
      EOF
  environment:
    name: production
  only:
    - main


~~~


Buil прошел

![build](https://github.com/zatulik2606/Diplomnew/blob/main/screen/buildsuccess.jpg)


[ссылка на build](https://gitlab.com/zatulik2606/Diplomnew/-/jobs/6774169457)

Deploy прошел

![Deploy](https://github.com/zatulik2606/Diplomnew/blob/main/screen/deploysuccess.jpg)


[ссылка на deploy](https://gitlab.com/zatulik2606/Diplomnew/-/jobs/6774169460)

Приложение появилось в web

![appweb](https://github.com/zatulik2606/Diplomnew/blob/main/screen/myappweb.jpg)



Также после сборки приложение появилось в [registry gitlab](registry.gitlab.com/zatulik2606/diplomnew:4cd6fdb8)

![gitlabregistry](https://github.com/zatulik2606/Diplomnew/blob/main/screen/deployingitlabregistry.jpg)


Смотрим в kuber кластер

~~~
root@debianv:~/diplomnew/bucket# kubectl get svc
NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes        ClusterIP   10.233.0.1      <none>        443/TCP        7d19h
myapp-myapp       NodePort    10.233.54.38    <none>        80:30880/TCP   2d2h
web-app-service   NodePort    10.233.39.139   <none>        80:30000/TCP   60m

~~~

Добавил tag 1.0.0

![tag])(https://github.com/zatulik2606/Diplomnew/blob/main/screen/tag1.0.0.jpg)

Вот , что видим в web

![appweb1.0](https://github.com/zatulik2606/Diplomnew/blob/main/screen/appaftertag1.0.0.jpg)


Добавил tag 1.0.2

![tag102](https://github.com/zatulik2606/Diplomnew/blob/main/screen/tag%201.0.2.png)


Как появилось в web

![tag102](https://github.com/zatulik2606/Diplomnew/blob/main/screen/appaftertag1.0.2.jpg)


Все, что собиралось в регистри, появилось в контейнерах Gitlab как образы  [тут](https://gitlab.com/zatulik2606/Diplomnew/container_registry/6352987).

Скрин сборок прилагаю.

![imagesregistry](https://github.com/zatulik2606/Diplomnew/blob/main/screen/versiongeristry.png)

---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

