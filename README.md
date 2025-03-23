# Blog

## 개요

블로그 설치 및 실행 관련 명령어를 기록

## 패키지 설치

최초 설정

```bash
bundle config set --local path 'vendor/bundle'
bundle init
```

jekyll 설치

```bash
bundle add jekyll
bundle install
```

## 블로그 첫 생성

대상 디렉터리가 비어있지 않다면 `--force` 옵션이 필요하다.

```bash
bundle exec jekyll new . --blank --force
```

서브 디렉터리에 생성하는 경우

```bash
bundle exec jekyll new subdir --blank
```

### 블로그 실행

서브 디렉터리에 대해 실행하는 경우 `--source` 옵션으로 명시

```bash
bundle exec jekyll serve --source subdir --livereload
```