# Groupe de sarped_e 941855

#### Repo - Github : <https://github.com/emmanuel-sarpedon/vinted-backend>

#### API : <https://api-vinted.herokuapp.com/>

---

# /!\ Prerequisite

```zsh
minikube start #create cluster and start minikube service

#to run local docker image on k8s, if public registry used, these commands are not necessary
minikube docker-env
eval $(minikube -p minikube docker-env) 
```

## Step 1 - Docker
```zsh
docker build -t local/vinted . #build image - only on first use
docker run -dp 4242:3000 local/vinted #run image and forward API port 3000 to host port 4242
```
ou en prévision d'un pull sur le registry Docker Hub

```zsh
docker build -t emmanuelsarpedon/vinted:latest .
docker run -dp 4242:3000 emmanuelsarpedon/vinted

docker ps #identify the container and note its id
docker commit <containerID>
docker push emmanuelsarpedon/vinted:latest
```

## Step 2 - Kubernetes - Run local image on pod
```zsh
#here kubectl command is an alias for 'minikube kubectl --'
kubectl run vinted-pod --image='local/vinted' --image-pull-policy='Never' --expose=true --port=3000
kubectl port-forward vinted-pod 4242:3000
```
ou créer un déploiement à partir d'une image stockée sur Docker Hub

```zsh
kubectl create deployment vinted --image=emmanuelsarpedon/vinted:latest
kubectl scale --replicas=3 deployment vinted #3 replicas (2 new pods created)
kubectl expose deployment vinted --type=LoadBalancer --port=4242 --target-port=3000 #expose pods port 3000 on port 4242 local
minikube tunnel

kubectl get service
> NAME         TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE
> kubernetes   ClusterIP      10.96.0.1     <none>        443/TCP          7d1h
> vinted       LoadBalancer   10.105.3.33   10.105.3.33   4242:32104/TCP   7m52s
```

on peut se connecter en local sur l'adresse 10.105.3.33:4242 pour accéder à l'API

## Step 3 - Helm
```zsh
helm install vinted-chart ./helm/vinted/ --values ./helm/vinted/values.yaml

export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services vinted-chart)
export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
echo http://$NODE_IP:$NODE_PORT
```

---

## 1 - Inscription d'un nouvel utilisateur

- Méthode `POST`

```
/user/signup
```

- Exemple de paramètres attendus

```json
{
  "username": "emmanuels",
  "password": "bestmdpever",
  "email": "emmanuel@vinted.com",
  "phone": "+33666778899"
}
```

- Exemple de réponse

```json
{
  "id": "60f660cfa865080015e73b54",
  "email": "emmanuel@vinted.com",
  "account": {
    "username": "emmanuels",
    "phone": "+33666778899",
    "avatar": null
  },
  "token": "a3cmqA2yIOhpxp2I"
}
```

## 2 - Connexion d'un utilisateur

- Méthode `POST`

```
/user/login
```

- Exemple de paramètres attendus

```json
{
  "email": "emmanuel@vinted.com",
  "password": "bestmdpever"
}
```

- Exemple de réponse

```json
{
  "_id": "60f660cfa865080015e73b54",
  "token": "a3cmqA2yIOhpxp2I",
  "account": {
    "username": "emmanuels",
    "phone": "+33666778899",
    "avatar": null
  }
}
```

<span style="color: red">🚨 Notez le `token` car vous en aurez besoin pour simuler la présence d'un cookie et publier / modifier une offre. Il faudra préciser le `Bearer Token` comme sur la capture d'écran ci-dessous pour toutes les routes ci-après</span>

![token](https://res.cloudinary.com/manu-sarp/image/upload/v1626761063/screenshots/token_bxomys.png)

## 3 - Publication d'une offre

- Méthode `POST`

```
/offer/publish
```

- Exemple de paramètres attendus

`form-data`

![offer/publish](https://res.cloudinary.com/manu-sarp/image/upload/v1626760935/screenshots/offer_publish_elkhvd.png)

- Exemple de réponse

```json
{
  "product_details": [
    {
      "MARQUE": "LACOSTE"
    },
    {
      "TAILLE": "M"
    },
    {
      "ÉTAT": "Neuf"
    },
    {
      "COULEUR": "Vert"
    },
    {
      "EMPLACEMENT": "Paris"
    }
  ],
  "_id": "60f667d3a865080015e73b58",
  "product_name": "Polo Lacoste",
  "product_description": "Polo Lacoste en parfait été",
  "product_price": 50,
  "owner": {
    "account": {
      "username": "emmanuels",
      "phone": "+33666778899",
      "avatar": null
    },
    "_id": "60f660cfa865080015e73b54",
    "token": "a3cmqA2yIOhpxp2I"
  },
  "product_image": {
    "asset_id": "f1ed7487fce6556a28bb256f4aa36e30",
    "public_id": "vinted/offers/60f667d3a865080015e73b58/nffqt6bj2lkxgtxiafaz",
    "version": 1626761172,
    "version_id": "2859a44bc503722c2efd9e0b59686de1",
    "signature": "19a4c96458877bdd0c6da80fbc19eac5a946002c",
    "width": 225,
    "height": 225,
    "format": "jpg",
    "resource_type": "image",
    "created_at": "2021-07-20T06:06:12Z",
    "tags": [],
    "bytes": 4228,
    "type": "upload",
    "etag": "8fc66ba662369e0d4824d59b6a9359f5",
    "placeholder": false,
    "url": "http://res.cloudinary.com/manu-sarp/image/upload/v1626761172/vinted/offers/60f667d3a865080015e73b58/nffqt6bj2lkxgtxiafaz.jpg",
    "secure_url": "https://res.cloudinary.com/manu-sarp/image/upload/v1626761172/vinted/offers/60f667d3a865080015e73b58/nffqt6bj2lkxgtxiafaz.jpg",
    "original_filename": "upload_57e8c4ca0a05afd3b32fac7bd158e4ae",
    "api_key": "311651436216244"
  },
  "__v": 0
}
```

## 4 - Visualisation des offres

### 4.1 Toutes les offres

- Méthode `GET`

```
/offers
```

### 4.2 Une offre en particulier

- Méthode `GET`

```
/offer/:id
```

- Paramètres facultatifs :

| filtre   | description                          |
| -------- | ------------------------------------ |
| title    | filtre sur la description des offres |
| priceMin | prix minimum                         |
| priceMax | prix maximum                         |

- Exemple de réponse

```json
{
  "count": 1,
  "offers": [
    {
      "product_details": [
        {
          "MARQUE": "LACOSTE"
        },
        {
          "TAILLE": "M"
        },
        {
          "ÉTAT": "Neuf"
        },
        {
          "COULEUR": "Vert"
        },
        {
          "EMPLACEMENT": "Paris"
        }
      ],
      "_id": "60f667d3a865080015e73b58",
      "product_name": "Polo Lacoste",
      "product_description": "Polo Lacoste en parfait été",
      "product_price": 50,
      "owner": "60f660cfa865080015e73b54",
      "product_image": {
        "asset_id": "f1ed7487fce6556a28bb256f4aa36e30",
        "public_id": "vinted/offers/60f667d3a865080015e73b58/nffqt6bj2lkxgtxiafaz",
        "version": 1626761172,
        "version_id": "2859a44bc503722c2efd9e0b59686de1",
        "signature": "19a4c96458877bdd0c6da80fbc19eac5a946002c",
        "width": 225,
        "height": 225,
        "format": "jpg",
        "resource_type": "image",
        "created_at": "2021-07-20T06:06:12Z",
        "tags": [],
        "bytes": 4228,
        "type": "upload",
        "etag": "8fc66ba662369e0d4824d59b6a9359f5",
        "placeholder": false,
        "url": "http://res.cloudinary.com/manu-sarp/image/upload/v1626761172/vinted/offers/60f667d3a865080015e73b58/nffqt6bj2lkxgtxiafaz.jpg",
        "secure_url": "https://res.cloudinary.com/manu-sarp/image/upload/v1626761172/vinted/offers/60f667d3a865080015e73b58/nffqt6bj2lkxgtxiafaz.jpg",
        "original_filename": "upload_57e8c4ca0a05afd3b32fac7bd158e4ae",
        "api_key": "311651436216244"
      },
      "__v": 0
    }
  ]
}
```

## 5 - Modifier une offre

🚨 Pour les routes `offer/update`et `offer/delete/:id` le token utilisateur doit correspondre au token de l'utilisateur propriétaire de l'annonce. Sinon, vous aurez la réponse suivante de la part du serveur :

```json
{
  "error": "Unauthorized"
}
```

- Méthode `PUT`

```
offer/update
```

- Paramètre obligatoire

```json
{
  "id": "60f667d3a865080015e73b58" // id de l'offre à modifier
}
```

- Au moins un de ses paramètres est attendu :

```json
{
      "brand": String,
      "size": String,
      "condition": String,
      "color": String,
      "city": String,
      "name": String,
      "description": String,
      "price": Number,
      "picture": File
}
```

- Exemple de requête

```json
{
  "id": "60f667d3a865080015e73b58", // id de l'offre
  "brand": "Lacoste - France" // paramètre "MARQUE" à modifier
}
```

- Exemple de réponse

```json
{
  "message": "Update OK",
  "offer": {
    "product_details": [
      {
        "MARQUE": "Lacoste - France"
      },
      {
        "TAILLE": "M"
      },
      {
        "ÉTAT": "Neuf"
      },
      {
        "COULEUR": "Vert"
      },
      {
        "EMPLACEMENT": "Paris"
      }
    ],
    "_id": "60f667d3a865080015e73b58",
    "product_name": "Polo Lacoste",
    "product_description": "Polo Lacoste en parfait été",
    "product_price": 50,
    "owner": "60f660cfa865080015e73b54",
    "product_image": {
      "asset_id": "f1ed7487fce6556a28bb256f4aa36e30",
      "public_id": "vinted/offers/60f667d3a865080015e73b58/nffqt6bj2lkxgtxiafaz",
      "version": 1626761172,
      "version_id": "2859a44bc503722c2efd9e0b59686de1",
      "signature": "19a4c96458877bdd0c6da80fbc19eac5a946002c",
      "width": 225,
      "height": 225,
      "format": "jpg",
      "resource_type": "image",
      "created_at": "2021-07-20T06:06:12Z",
      "tags": [],
      "bytes": 4228,
      "type": "upload",
      "etag": "8fc66ba662369e0d4824d59b6a9359f5",
      "placeholder": false,
      "url": "http://res.cloudinary.com/manu-sarp/image/upload/v1626761172/vinted/offers/60f667d3a865080015e73b58/nffqt6bj2lkxgtxiafaz.jpg",
      "secure_url": "https://res.cloudinary.com/manu-sarp/image/upload/v1626761172/vinted/offers/60f667d3a865080015e73b58/nffqt6bj2lkxgtxiafaz.jpg",
      "original_filename": "upload_57e8c4ca0a05afd3b32fac7bd158e4ae",
      "api_key": "311651436216244"
    },
    "__v": 1
  }
}
```

## 5 - Supprimer une offre

- Méthode `DELETE`

```
offer/delete/:id
```

- Exemple de requête

```
offer/delete/60f667d3a865080015e73b58
```

- Exemple de réponse

```json
{
  "message": "Offer deleted",
  "offerDeleted": {
    "product_details": [
      {
        "MARQUE": "Lacoste - France"
      },
      {
        "TAILLE": "M"
      },
      {
        "ÉTAT": "Neuf"
      },
      {
        "COULEUR": "Vert"
      },
      {
        "EMPLACEMENT": "Paris"
      }
    ],
    "_id": "60f667d3a865080015e73b58",
    "product_name": "Polo Lacoste",
    "product_description": "Polo Lacoste en parfait été",
    "product_price": 50,
    "owner": "60f660cfa865080015e73b54",
    "product_image": {
      "asset_id": "f1ed7487fce6556a28bb256f4aa36e30",
      "public_id": "vinted/offers/60f667d3a865080015e73b58/nffqt6bj2lkxgtxiafaz",
      "version": 1626761172,
      "version_id": "2859a44bc503722c2efd9e0b59686de1",
      "signature": "19a4c96458877bdd0c6da80fbc19eac5a946002c",
      "width": 225,
      "height": 225,
      "format": "jpg",
      "resource_type": "image",
      "created_at": "2021-07-20T06:06:12Z",
      "tags": [],
      "bytes": 4228,
      "type": "upload",
      "etag": "8fc66ba662369e0d4824d59b6a9359f5",
      "placeholder": false,
      "url": "http://res.cloudinary.com/manu-sarp/image/upload/v1626761172/vinted/offers/60f667d3a865080015e73b58/nffqt6bj2lkxgtxiafaz.jpg",
      "secure_url": "https://res.cloudinary.com/manu-sarp/image/upload/v1626761172/vinted/offers/60f667d3a865080015e73b58/nffqt6bj2lkxgtxiafaz.jpg",
      "original_filename": "upload_57e8c4ca0a05afd3b32fac7bd158e4ae",
      "api_key": "311651436216244"
    },
    "__v": 1
  }
}
```
