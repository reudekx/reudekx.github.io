---
created_date: 2024-11-11
modified_date: 2024-11-11
copyright: © 2024 reudekx · CC BY 4.0
---

# Git

## 개요

Git을 사용하면서 겪은 문제해결 과정이나 명령어들을 정리하였다.

## Rebase

`git push`를 하였더니 다음과 같은 오류가 출력되었다.

```shell
❯ git push origin main
To reudekx:reudekx/reudekx.github.io.git
 ! [rejected]        main -> main (non-fast-forward)
error: failed to push some refs to 'reudekx:reudekx/reudekx.github.io.git'
```
따라서 아래의 명령어를 통해 확인해보았다.

```bash
# 로컬의 커밋 히스토리 확인
git log --oneline main # 혹은 단순하게 git log --oneline
# 원격의 커밋 히스토리 확인
git log --oneline origin/main
# 두 브랜치를 비교
git log --oneline --graph main origin/main # 혹은 단순하게 git log --oneline --graph --all
```
다른 컴퓨터에서 문서 내용을 업데이트했던 것을 pull하지 않아 문제가 발생한 것이었다.
혼자 사용하는 저장소이며 실수로 인해 벌어진 일이기도 하므로,
`git rebase`를 통해 문제를 해결하기로 하였다.

```bash
git pull --rebase origin main
# 혹은 git fetch origin && git rebase origin/main
```

실행 결과 충돌이 발생하지 않아 즉시 rebase가 완료되었다.

## 커밋 메시지 수정

커밋 메시지를 잘못 적었을 때 수정하는 방법을 알아보자.

먼저 가장 최근 커밋 메시지를 수정하는 명령어는 다음과 같다.

```bash
git commit --amend -m "새로운 커밋 메시지"
```

이전 커밋의 메시지를 수정하고 싶다면 `git rebase`를 이용한다.

```bash
# -i 옵션을 통해 대화형 인터페이스를 실행한다.
# rebase는 지정한 커밋을 기준으로 다음 커밋부터 재작성하므로,
# HEAD~3의 경우는 HEAD~2, HEAD~1, HEAD가 재작성의 대상이 된다.
# HEAD^^^로 대신할 수 있다.
git rebase -i HEAD~3 
```
