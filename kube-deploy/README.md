# Deploy with Kustomize


Edit the `kustomization.yaml` file in the `dev` or `prod` folder inserting the proper values.
Then:

```bash
kustomize build dev > dev-manifest.yaml
kubectl apply -f dev-manifest.yaml
```

or

```bash
kustomize build prod > prod-manifest.yaml
kubectl apply -f prod-manifest.yaml
```
