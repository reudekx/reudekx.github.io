---
created_date: 2024-11-11
modified_date: 2024-11-11
copyright: © 2024 reudekx · CC BY 4.0
---

# Git

## 개요

Git을 사용하면서 겪은 문제해결 과정이나 명령어들을 정리하였다.

### 충돌 해결

`git push`를 하였더니 다음과 같은 오류가 출력되었다.

```shell
❯ git push origin main
To reudekx:reudekx/reudekx.github.io.git
 ! [rejected]        main -> main (non-fast-forward)
error: failed to push some refs to 'reudekx:reudekx/reudekx.github.io.git'
```
따라서 다음과 같은 명령어를 통해 확인해보았다.

```bash
# 로컬의 커밋 히스토리 확인
git log --oneline main
# 원격의 커밋 히스토리 확인
git log --oneline origin/main
# 두 브랜치를 비교
git log --oneline --graph main origin/main
```
다른 컴퓨터에서 문서 내용을 업데이트했던 것을 pull하지 않아 문제가 발생했다.
혼자 사용하는 저장소이며 실수로 인해 벌어진 일이기도 하므로,
`git rebase`를 통해 문제를 해결하기로 하였다.

```bash
git pull --rebase origin main
# 혹은 git fetch origin && git rebase origin/main
```