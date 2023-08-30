Работа состоит из двух репозиториев: Terraform (репозиторий с кодом инфраструктуры) и App (репозиторий приложения).

**Репозиторий Terraform состоит из:**
-	Папки gitlab-runner (стандартный helm chart с не большими изменениями, например   tags: "cloud-k8s");
-	Папки terraform c кодом;
-	Файлов .gitlab-ci.yaml, файла манифеста для серт менеджера и скрипта для подготовки БД приложения.

**Конвейер Terraform состоит из 9 этапов:**
  - lint (yaml-lint и terraform-validate выполняющиеся одновременно)
  - build (terraform-build, файл билда сохраняется и именно он разворачивается на этапе деплоя)
  - deploy-terraform (деплой всей инфраструктуры)
  - install-gitlab-runner (установка гитлаб раннера в кубернетес, прописывается автоматически)
  - install-certmanager (установка серт менеджера для выпуска сертификата)
  - install-ingress (установка ингресса для приложения)
  - install-redis (установка редиса)
  - prepare-db (подготовка БД для приложения)
  - destroy-terraform (уничтожение инфраструктуры).

**Этапы конвейера App:**
  - lint (линтер helm и yaml, запуск одновременный)
  - build (сборка app-server, app-ui)
  - test (собранные образы поднимаются в Compose и проверяется работа приложения Curl)
  - deploy-token (Если токена для деплоя приложения нет – то он создается)
  - deploy (разворачивание образов в Kube)
  - rollback (удаление приложения).

**Необходимые переменные:**

AWS_ACCESS_KEY_ID
- Default:
- Properties: Protected 
- Description: Получаем согласно инструкции ниже, нужен для работы S3.

AWS_SECRET_ACCESS_KEY
- Default: 
- Properties: Protected Masked
- Description: Получаем согласно инструкции ниже, нужен для работы S3

GITLAB_PRIVATE_TOKEN
- Default: 
- Properties: Protected Masked
- Description: Получаем в настройках гитлаба, для того чтобы выкладывались образы в регистр.

SA_KEY
- Default: 
- Properties: Protected Masked
- Description: Получаем согласно инструкции ниже, нужен для работы terraform.

SSH_OPEN_KEY
- Default: 
- Properties: Protected Masked
- Description: Нужен для возможности авторизоваться в кластер kube. Получаем с помощью ssh-keygen -t ed25519

SSH_USER
- Default: <Любое имя пользователя на англ. языке>
- Properties: Expanded 
- Description: Нужен для возможности авторизоваться в кластер kube. Получаем с помощью ssh-keygen -t ed25519

TF_VAR_YC_CLOUD_ID
- Default: 
- Properties: Protected
- Description: Получаем export YC_CLOUD_ID=$(yc config get cloud-id);

TF_VAR_YC_FOLDER_ID
- Default: 
- Properties: Protected
- Description: Получаем export YC_FOLDER_ID=$(yc config get folder-id);

YELB_APP_DNS_NAME
- Default: <Любое доменное имя оформленное и делегированное для проекта>
- Properties: Expanded 
- Description: 

YELB_DB_NAME
- Default: <Любое имя БД>
- Properties: Expanded 
- Description: 

YELB_DB_PASS
- Default: <Любой пароль>
- Properties: Protected Masked
- Description: 

YELB_DB_PORT
- Default: 6432
- Properties: Expanded 
- Description: 

YELB_DB_USER 
- Default: <Любое имя пользователя>
- Properties: Expanded 
- Description: 

YELB_GROUP_GITLAB_API_LINK
- Default: `$CI_SERVER_PROTOCOL://$CI_SERVER_HOST/api/v4/groups/$CI_PROJECT_NAMESPACE`
- Properties: Expanded 
- Description: Переменная нужна для работы конвейера. Не изменять без необходимости. Копировать без ковычек.

**Получение данных для переменных:**
```
yc iam service-account create --name yelb-deploy
# Создаем сервис аккаунт.
yc resource-manager folder add-access-binding --service-account-name yelb-deploy --role editor default
# Даём права на создание объектов в папке облака.
yc iam key create --service-account-name yelb-deploy --output sa-key.json
# В этом пункте мы получаем SA_KEY для основного разворачивания terraform манифестов.

#Даем необходимые права для безпроблемного разворачивания:
yc resource-manager folder add-access-binding --service-account-name yelb-deploy --role ydb.admin default
yc resource-manager folder add-access-binding --service-account-name yelb-deploy --role ydb.editor default
yc resource-manager folder add-access-binding --service-account-name yelb-deploy --role storage.uploader default
yc resource-manager folder add-access-binding --service-account-name yelb-deploy --role admin default
yc iam access-key create --service-account-name yelb-deploy
# Получаем данные для переменных AWS_SECRET_ACCESS_KEY и AWS_ACCESS_KEY_ID
```


**Порядок разворачивания:**
1. Развернуть Gitlab и локальный раннер для него.
2. Создаем сервис аккаунт, БД YMC, бакет, создаем таблицу для s3.
2. Создаем группу для репозиториев и заносим в нее все переменные.
3. Делаем форк проектов и наблюдаем за процессом.

**Нюансы:**
1. Для первого разворачивания Terraform используется любой внешний раннер (я использовал docker),
после первого деплоя уже будет в работе раннер развернутый в кластере kube.
2. Оба репозитория должны находится в одной группе, переменные добавляются в группу.
3. Проверяйте переменные.
4. Мониторинг и логирование осуществляется встроенными инструментами Яндекса. В облаке есть несколько дашбордов.
5. Все этапы конвейера Terraform выполняющих деплой запускаются вручную.

**Предложения для команды разработки \ планы на дальнейшую работу:**
1. Проверьте код ruby, чтобы проходил линтеры. После мы добавим их в конвейер.
2. Добавьте метрики для микросервисов приложения. После этого можно будет развернуть стек мониторинга и логирования.
3. Оптимизировать Dockerfile app-server.
