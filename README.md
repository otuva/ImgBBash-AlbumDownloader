# ImgBBashAlbumDownloader
Bash script to download albums from https://ibb.co

---

### Usage:
`bash script.sh <album_id>`

#### Example:
```
#https://ibb.co/album/aaaaaa
bash script.sh aaaaaa
```

- Script will skip files with existing names and won't overwrite.
- It uses curl and jq make sure they are installed.
