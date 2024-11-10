---
created_date: 2024-11-05
modified_date: 2024-11-11
copyright: © 2024 reudekx · CC BY 4.0
---

# C++

## 개요

C++(버전 17 이후)의 문법과 기능을 정리하였다.

C++을 프로젝트에서 사용하게 되면서 언어에 대한 공부를 하향식으로 진행하고 있는데,
필요시 교재를 구매할 예정이다.
개인 공부용으로 정리한 것이므로 이 문서에 적힌 내용은 공식 문서 등을 참고하여 교차 검증할 필요가 있다.
나중에 댓글 기능을 추가하여 피드백을 받을 수 있도록 해야겠다..

실제로도 공부를 하면서 다른 블로그의 글을 살펴볼 때
엄밀하지 않거나, 잘못되거나 모호한 정보가 서술된 경우를 발견하기도 하였다.
따라서 이 문서도 그러한 정보가 있을 수 있음에 유의할 것.


## 문법과 기능

### 값 범주

C++의 모든 **표현식**은 **타입(type)**과 **값 범주(value category)**라는
2가지 독립된 속성을 지닌다.
특히 **값 범주**는 표현식의 **의미론적 특성**으로서,
C++ 컴파일러가 표현식을 어떻게 처리할지를 결정할 때 중요한 역할을 하게 된다.
가령 `1 = 2`와 같은 표현식을 컴파일러는 어떻게 처리해야 할까?
**타입**이라는 속성만으로는 해당 표현식의 유효성을 판별할 수 없을 것이고,
`1`이라는 숫자 표현식이 대입 연산자의 좌변에 올 수 없음을 판단하기 위한
추가적인 속성이 필요하며 이때 **값 범주**가 그 역할을 수행하게 된다.

먼저 모든 표현식은 다음의 세 가지 주 범주 중 하나에 속하게 된다.

* **lvalue (Left value)**
* **xvalue (eXpiring value)**
* **prvalue (Pure rvalue)**

또한 아래와 같은 혼합 범주가 상위 범주로서 존재한다.

* **glvalue (Generalized lvalue)**
    * lvalue \| xvalue
* **rvalue (Right value)**
    * xvalue \| prvalue


이제 각 범주가 무엇을 의미하는 것인지 알아보자.
다만 혼합 범주의 경우 세 가지 주 범주에 대해 알고나면
자연스럽게 파악이 되므로, 그에 대한 설명은 생략하도록 하겠다.

* **lvalue**
    * **identity를 가진다.**
        * 객체나 함수의 identity를 결정하는 표현식 (glvalue의 특성)
    * **이동될 수 없다.**
        * std::move 등을 이용해 xvalue로 변환을 해야 이동이 가능해진다.
        * 가령 함수에 대한 rvalue 참조는 이름의 유무와는 상관없이 lvalue로 취급된다.
            * 함수는 복사나 이동될 수 없고, 항상 동일한 주소에 있으므로

* **xvalue**
    * **identity를 가진다.** (lvalue와 마찬가지)
    * **이동될 수 있다.**
        * `std::move` 등을 이용하여 lvalue를 xvalue로 변환할 수 있다.
        * 다만 원본 객체가 const인 경우 이동 연산이 이뤄질 수 없다.
    * 개념적으로는 수명이 거의 끝나서 자원이 재사용될 수 있는 객체를 의미한다.

* **prvalue**
    * **identity를 가지지 않는다.**
    * **이동될 수 없다.**
        * C++17부터는 prvalue는 필요할 때까지 구체화되지 않으며, 최종 목적지에 직접적으로 구성된다.
        * 따라서 복사/이동이 이뤄지지 않는다.

자세한 정보는 [링크](https://en.cppreference.com/w/cpp/language/value_category#glvalue)를 통해 참고하도록 하고,
코드를 통해 실제로 어떤 표현식이 어떠한 범주에 속하는지 확인해 보자.

```cpp
#include <iostream>
#include <utility>

template<typename T>
constexpr auto VALUE_CATEGORY = "prvalue";

template<typename T>
constexpr auto VALUE_CATEGORY<T&> = "lvalue";

template<typename T>
constexpr auto VALUE_CATEGORY<T&&> = "xvalue";

#define PRINT_VALUE_CATEGORY(expr) \
    std::cout << #expr << " is " << VALUE_CATEGORY<decltype((expr))> << std::endl

struct Object {
    int val = 1;
};

Object create_object() { 
    return Object{}; 
}

int main() {
    Object obj;
    
    PRINT_VALUE_CATEGORY(Object{}); // prvalue
    PRINT_VALUE_CATEGORY(obj); // lvalue
    PRINT_VALUE_CATEGORY(std::move(obj)); // xvalue
    
    PRINT_VALUE_CATEGORY(obj.val); // lvalue
    PRINT_VALUE_CATEGORY(Object{}.val); // xvalue
    PRINT_VALUE_CATEGORY(*(&obj)); // lvalue

    PRINT_VALUE_CATEGORY((const Object&)Object{}); // lvalue
    PRINT_VALUE_CATEGORY((const Object&)obj); // lvalue
    PRINT_VALUE_CATEGORY(std::move((const Object&)obj)); // xvalue (하지만 이동은 불가)
    
    PRINT_VALUE_CATEGORY(create_object); // lvalue
    PRINT_VALUE_CATEGORY(std::move(create_object)); // lvalue
    PRINT_VALUE_CATEGORY((Object(&&)())create_object); // lvalue
    PRINT_VALUE_CATEGORY(create_object()); // prvalue
    
    return 0;
}
```

`decltype` 지정자를 통해 어떻게 값 범주를 확인할 수 있는지는
[링크](https://en.cppreference.com/w/cpp/language/decltype)를 참고할 것.

위 코드를 실행시켜 여러 표현식에 대한 값 범주를 확인해 볼 수 있다.
다만 다음의 코드를 다시 살펴보도록 하자.

```cpp
std::move((const Object&)obj)
```

주석에도 적어놨지만, 위 표현식의 경우 **xvalue**지만 이동은 불가능하다.
코드를 살펴보면 `std::move`를 통해 `const Object&&` 타입으로 형변환되는데,
이동 연산을 위해서는 이동 생성자 혹은 이동 대입 연산자를 선택해야 하지만 
const 한정자로 인해 오버로드 해결(overload resolution) 과정에서
`const Object&` 타입의 매개변수를 갖는 함수가 선택되고,
이는 복사 생성자 혹은 복사 대입 연산자이므로 이동 대신 복사 연산이 이뤄지게 된다.
(애초에 const 객체는 수정이 불가능하므로 이동 연산의 대상이 될 수 없기도 하다.)

## 참고 웹사이트

* [https://en.cppreference.com/w/](https://en.cppreference.com/w/) - C++ 레퍼런스
* [https://godbolt.org/](https://godbolt.org/) - 간편하게 C/C++ 코드를 어셈블리어로 컴파일하여 확인 가능
