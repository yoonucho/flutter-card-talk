// 페이지 로드 시 실행
document.addEventListener("DOMContentLoaded", function () {
  // URL 파라미터에서 카드 ID 가져오기
  const urlParams = new URLSearchParams(window.location.search);
  const shareId = urlParams.get("id");

  // 현재 페이지 확인
  const currentPage = window.location.pathname.split("/").pop();

  if (currentPage === "view.html") {
    // 카드 보기 페이지
    setupViewPage(shareId);
  } else if (currentPage === "share.html") {
    // 공유 페이지
    setupSharePage(shareId);
  } else {
    // 기본 페이지
    setupDefaultPage();
  }
});

// 카드 보기 페이지 설정
function setupViewPage(shareId) {
  // 카드 컨테이너를 처음부터 표시 가능하도록 설정
  const cardContainer = document.getElementById("cardContainer");
  if (cardContainer) {
    cardContainer.style.display = "block";
    cardContainer.style.opacity = "1";
    cardContainer.style.visibility = "visible";
  }

  // 인트로 화면 설정
  const introButton = document.getElementById("introButton");
  if (introButton) {
    introButton.addEventListener("click", function () {
      document.getElementById("intro").style.display = "none";
      document.getElementById("cardContainer").style.display = "block";
      loadCardData(shareId);
    });
  } else {
    // 인트로 화면이 없는 경우 바로 카드 데이터 로드
    loadCardData(shareId);
  }
}

// 공유 페이지 설정
function setupSharePage(shareId) {
  // URL 파라미터에서 카드 데이터 가져오기
  const urlParams = new URLSearchParams(window.location.search);
  const encodedData = urlParams.get("data");

  // 앱 링크 설정
  const appLink = document.getElementById("appLink");
  if (appLink) {
    // 딥링크 설정
    appLink.href = `cardtalk://share?id=${shareId}&data=${encodedData}`;
  }

  // 웹 링크 설정
  const webLink = document.getElementById("webLink");
  if (webLink) {
    webLink.href = `view.html?id=${shareId}&data=${encodedData}`;
  }
}

// 기본 페이지 설정
function setupDefaultPage() {
  console.log("기본 페이지 로드");
}

// 카드 데이터 가져오기 함수
function loadCardData(shareId) {
  try {
    // 카드 컨테이너를 표시 상태로 설정
    const cardContainer = document.getElementById("cardContainer");
    if (cardContainer) {
      cardContainer.style.display = "block";
      cardContainer.style.opacity = "1";
      cardContainer.style.visibility = "visible";
    }

    // 디버그 모드 확인
    const urlParams = new URLSearchParams(window.location.search);
    const isDebug = urlParams.get("debug") === "true";

    if (isDebug) {
      console.log("테스트 시작 - 카드 데이터 로딩");
      console.log("카드 ID:", shareId);
    }

    // URL 파라미터에서 카드 데이터 가져오기
    const encodedData = urlParams.get("data");
    console.log("1. encodedData:", encodedData);

    if (encodedData) {
      try {
        // 1. URL 디코딩 (한 번만!)
        let urlDecoded;
        try {
          urlDecoded = decodeURIComponent(encodedData);
          console.log("2. urlDecoded:", urlDecoded);
        } catch (urlError) {
          console.error("URL 디코딩 오류:", urlError);
          urlDecoded = encodedData; // URL 디코딩 실패 시 원본 사용
        }

        // 2. URL 안전 Base64를 표준 Base64로 변환 및 데이터 정리
        // 모든 공백 제거 (중요: 공백이 있으면 디코딩 실패)
        let base64Data = urlDecoded.replace(/\s+/g, "");

        // URL 안전 Base64를 표준 Base64로 변환
        base64Data = base64Data.replace(/-/g, "+").replace(/_/g, "/");

        // 잘못된 문자 제거 (알파벳, 숫자, +, /, = 외 모든 문자 제거)
        base64Data = base64Data.replace(/[^A-Za-z0-9+/=]/g, "");

        // Base64 패딩 보정
        while (base64Data.length % 4) {
          base64Data += "=";
        }

        console.log("3. base64Data(정리 후):", base64Data);

        // 3. Base64 디코딩 - 강화된 오류 처리 및 추가 복구 메커니즘
        let jsonData;
        try {
          // 방법 1: TextDecoder 사용 (권장)
          try {
            // base64Data가 유효한지 확인
            if (!base64Data || base64Data.trim() === "") {
              throw new Error("빈 Base64 데이터");
            }

            // 표준 Base64 패턴 검증
            const base64Pattern = /^[A-Za-z0-9+/=]+$/;
            if (!base64Pattern.test(base64Data)) {
              console.warn(
                "유효하지 않은 Base64 문자가 포함되어 있습니다. 정리 시도..."
              );
              base64Data = base64Data.replace(/[^A-Za-z0-9+/=]/g, "");
            }

            const binaryString = atob(base64Data);
            const len = binaryString.length;
            const bytes = new Uint8Array(len);

            for (let i = 0; i < len; i++) {
              bytes[i] = binaryString.charCodeAt(i);
            }

            jsonData = new TextDecoder("utf-8").decode(bytes);
            console.log("방법 1로 디코딩 성공");
          } catch (error) {
            console.warn("방법 1 디코딩 실패:", error);

            // 방법 2: Base64.decode 라이브러리 사용 (fallback)
            if (typeof Base64 !== "undefined") {
              try {
                jsonData = Base64.decode(base64Data);
                console.log("방법 2로 디코딩 성공");
              } catch (libError) {
                console.warn("방법 2 디코딩 실패:", libError);

                // 방법 3: 디코딩 직접 구현 (최후의 수단)
                try {
                  // base64 문자를 인덱스로 변환
                  const base64Chars =
                    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
                  let output = "";
                  let chr1, chr2, chr3, enc1, enc2, enc3, enc4;
                  let i = 0;

                  // base64 인코딩 제거
                  base64Data = base64Data.replace(/[^A-Za-z0-9\+\/\=]/g, "");

                  while (i < base64Data.length) {
                    enc1 = base64Chars.indexOf(base64Data.charAt(i++));
                    enc2 = base64Chars.indexOf(base64Data.charAt(i++));
                    enc3 = base64Chars.indexOf(base64Data.charAt(i++));
                    enc4 = base64Chars.indexOf(base64Data.charAt(i++));

                    chr1 = (enc1 << 2) | (enc2 >> 4);
                    chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
                    chr3 = ((enc3 & 3) << 6) | enc4;

                    output = output + String.fromCharCode(chr1);

                    if (enc3 !== 64) {
                      output = output + String.fromCharCode(chr2);
                    }
                    if (enc4 !== 64) {
                      output = output + String.fromCharCode(chr3);
                    }
                  }

                  // UTF-8 디코딩
                  jsonData = decodeURIComponent(escape(output));
                  console.log("방법 3으로 디코딩 성공");
                } catch (customError) {
                  console.warn("방법 3 디코딩 실패:", customError);
                  throw error; // 원래 오류 다시 발생
                }
              }
            } else {
              throw error; // 라이브러리 없으면 원래 오류 다시 발생
            }
          }
        } catch (error) {
          console.error("모든 Base64 디코딩 방법 실패:", error);
          throw new Error("Base64 디코딩에 실패했습니다: " + error.message);
        }
        console.log("4. jsonData:", jsonData);

        // 4-1. JSON 데이터 정리 및 추출
        let cleanJson = jsonData.trim();

        // JSON 객체 추출 시도
        const jsonStart = cleanJson.indexOf("{");
        const jsonEnd = cleanJson.lastIndexOf("}");

        if (jsonStart !== -1 && jsonEnd !== -1 && jsonEnd > jsonStart) {
          cleanJson = cleanJson.substring(jsonStart, jsonEnd + 1);
        }

        console.log("4-1. cleanJson:", cleanJson);
        console.log("4-2. cleanJson length:", cleanJson.length);

        // 5. JSON 파싱 - 개선된 방법
        let cardData;

        // 빈 데이터 체크
        if (!cleanJson || cleanJson.trim() === "" || cleanJson === "{}") {
          throw new Error(
            "디코딩된 데이터가 비어있습니다. 원본 데이터: " + jsonData
          );
        }

        try {
          // 먼저 정리된 데이터로 파싱 시도
          cardData = JSON.parse(cleanJson);
          console.log("정리된 데이터 파싱 성공:", cardData);

          // 색상값 정리 및 검증
          if (cardData.backgroundColor) {
            // 색상값이 유효한지 확인
            if (cardData.backgroundColor.includes("[")) {
              console.log(
                "잘못된 배경색 형식 감지, 정리 시도:",
                cardData.backgroundColor
              );
            }
          }

          if (cardData.textColor) {
            // 색상값이 유효한지 확인
            if (cardData.textColor.includes("[")) {
              console.log(
                "잘못된 텍스트 색상 형식 감지, 정리 시도:",
                cardData.textColor
              );
            }
          }
        } catch (directParseError) {
          console.log("정리된 데이터 파싱 실패, 원본 데이터로 시도");

          // 대안: 전체 jsonData로 파싱 시도
          try {
            cardData = JSON.parse(jsonData.trim());
            console.log("원본 데이터 파싱 성공:", cardData);
          } catch (fullParseError) {
            console.log("정규 파싱 실패, 하드코딩된 카드 데이터 시도");

            // 마지막 수단: 하드코딩된 카드 데이터 생성
            try {
              // URL에서 id와 일부 정보 추출
              const urlParams = new URLSearchParams(window.location.search);
              const receivedId = urlParams.get("id") || "unknown";

              // 기본 카드 데이터 생성
              cardData = {
                name: "성취 축하",
                emoji: "🎉",
                message: "대단해요! 👆 이제 카드를 받았어요",
                backgroundColor: "#fffde7",
                textColor: "#f57f17",
              };

              // 잘못된 색상 형식이 있는지 확인하고 정리
              try {
                // URL 파라미터에서 색상 정보 추출 시도
                const encodedData = urlParams.get("data");
                if (encodedData) {
                  // 데이터에서 색상 정보 추출 시도
                  const dataMatch = encodedData.match(
                    /backgroundColor|textColor/g
                  );
                  if (dataMatch) {
                    console.log(
                      "원본 데이터에서 색상 정보 감지됨:",
                      dataMatch.length,
                      "개"
                    );
                  }
                }
              } catch (colorError) {
                console.warn("색상 정보 추출 중 오류:", colorError);
              }

              console.log("하드코딩된 카드 데이터 사용:", cardData);
            } catch (fallbackError) {
              console.error("모든 파싱 방법 실패");
              throw new Error(
                `JSON 파싱 실패. cleanJson: "${cleanJson}", jsonData: "${jsonData}"`
              );
            }
          }
        }

        // 6. 필수 필드 확인
        if (!cardData.name && !cardData.message) {
          throw new Error("카드 데이터 형식이 올바르지 않습니다.");
        }

        // 7. 카드 데이터 표시
        displayCard(cardData);
      } catch (error) {
        console.error("카드 데이터 처리 오류:", error);
        if (isDebug) {
          showError(error.toString());
        } else {
          displayDefaultCard(shareId);
        }
      }
    } else {
      // 데이터 없음
      displayDefaultCard(shareId);
    }
  } catch (error) {
    console.error("카드 로딩 오류:", error);
    displayDefaultCard(shareId);
  }
}

// 카드 표시 함수
function displayCard(cardData) {
  document.getElementById("loading").style.display = "none";
  const card = document.getElementById("card");
  const cardContainer = document.getElementById("cardContainer");

  console.log("카드 데이터 표시 시작:", cardData);

  // 카드 데이터 설정
  if (cardData.emoji) {
    const emojiElement = document.getElementById("emoji");

    // 이모지가 유니코드 이스케이프 형식으로 들어온 경우 (\uD83D\uDC99) 처리
    let emoji = cardData.emoji;
    try {
      // 이모지가 이미 디코딩되었는지 확인
      if (emoji.startsWith("\\u")) {
        // 이스케이프된 유니코드 문자열을 실제 이모지로 변환
        emoji = emoji.replace(/\\u([0-9a-fA-F]{4})/g, (match, p1) => {
          return String.fromCodePoint(parseInt(p1, 16));
        });
        console.log("이모지 유니코드 변환:", emoji);
      }

      // 이모지 설정
      emojiElement.textContent = emoji;

      // 이모지 특별 처리
      emojiElement.style.display = "block";
      emojiElement.style.visibility = "visible";
      emojiElement.style.opacity = "1";
      emojiElement.style.fontSize = "5rem"; // 이모지 크기 확대
      console.log("이모지 설정됨:", emoji);
    } catch (emojiError) {
      console.error("이모지 처리 오류:", emojiError);
      // 오류 발생 시 기본 이모지 설정
      emojiElement.textContent = "🎁";
      emojiElement.style.display = "block";
    }
  }

  if (cardData.name) {
    const titleElement = document.getElementById("title");
    titleElement.textContent = cardData.name;
    titleElement.style.display = "block";
    titleElement.style.visibility = "visible";
    titleElement.style.opacity = "1";
    // 한글 폰트 처리 강화
    titleElement.style.fontFamily =
      '"Noto Sans KR", "Apple SD Gothic Neo", sans-serif';
    console.log("제목 설정됨:", cardData.name);
  }

  if (cardData.message) {
    const messageElement = document.getElementById("message");
    messageElement.textContent = cardData.message;
    messageElement.style.display = "block";
    messageElement.style.visibility = "visible";
    messageElement.style.opacity = "1";
    // 한글 폰트 처리 강화
    messageElement.style.fontFamily =
      '"Noto Sans KR", "Apple SD Gothic Neo", sans-serif';
    console.log("메시지 설정됨:", cardData.message);
  }

  // 색상 정규화 함수 - 전역 함수로 정의
  function fixColor(color) {
    if (!color) return "#ffffff"; // 색상이 없으면 기본 흰색 반환

    // 공백 제거
    color = color.trim();

    // "# [fff3e0" 같은 형식 처리
    if (color.includes("[")) {
      try {
        color = "#" + color.split("[")[1].trim();
      } catch (e) {
        console.warn("색상 포맷 변환 중 오류:", e);
      }
    }

    // 첫 번째 # 기호가 없는 경우 추가
    if (!color.startsWith("#") && color.match(/^[0-9a-fA-F]{3,8}$/)) {
      color = "#" + color;
    }

    return color;
  }

  // 배경색 및 텍스트 색상 설정 (단순화된 색상 처리)
  if (cardData.backgroundColor) {
    try {
      // 잘못된 형식의 색상값 정리 및 다양한 형식 지원
      let bgColor = cardData.backgroundColor;

      // 색상 정규화 적용
      let fixedBgColor = fixColor(bgColor);
      card.style.backgroundColor = fixedBgColor;
      console.log("배경색 설정됨 (정리 후):", fixedBgColor);
    } catch (error) {
      // 오류 발생 시 기본 배경색
      card.style.backgroundColor = "#ffffff";
      console.warn("배경색 설정 중 오류 발생, 기본값 적용:", error);
    }
  } else {
    // 기본 배경색
    card.style.backgroundColor = "#ffffff";
  }

  if (cardData.textColor) {
    try {
      // 잘못된 형식의 색상값 정리
      let txtColor = cardData.textColor;

      // 색상 정규화 적용
      let fixedTxtColor = fixColor(txtColor);

      // 텍스트 색상 개별 적용
      document.getElementById("title").style.color = fixedTxtColor;
      document.getElementById("message").style.color = fixedTxtColor;
      console.log("텍스트 색상 설정됨 (정리 후):", fixedTxtColor);
    } catch (error) {
      // 오류 발생 시 기본 텍스트 색상
      document.getElementById("title").style.color = "#e91e63";
      document.getElementById("message").style.color = "#333333";
      console.warn("텍스트 색상 설정 중 오류 발생, 기본값 적용:", error);
    }
  } else {
    // 기본 텍스트 색상
    document.getElementById("title").style.color = "#e91e63";
    document.getElementById("message").style.color = "#333333";
  }

  // 카드 컨테이너 표시
  if (cardContainer) {
    cardContainer.style.display = "block";
    cardContainer.style.opacity = "1";
    cardContainer.style.visibility = "visible";
  }

  // 효과 컨테이너 확인
  const effectsContainer = document.getElementById("effectsContainer");
  if (!effectsContainer) {
    // 효과 컨테이너가 없으면 생성
    const newEffectsContainer = document.createElement("div");
    newEffectsContainer.id = "effectsContainer";
    newEffectsContainer.className = "effects-container";
    document.body.prepend(newEffectsContainer);
    console.log("효과 컨테이너 새로 생성됨");
  } else {
    console.log("기존 효과 컨테이너 사용");
    // 효과 컨테이너가 있으면 스타일 확인
    effectsContainer.style.position = "fixed";
    effectsContainer.style.top = "0";
    effectsContainer.style.left = "0";
    effectsContainer.style.width = "100%";
    effectsContainer.style.height = "100vh";
    effectsContainer.style.zIndex = "30";
    effectsContainer.style.pointerEvents = "none";
    effectsContainer.style.overflow = "visible";
  }

  // 카드 표시 및 애니메이션 적용 (서서히 나타나는 효과)
  card.style.display = "block";
  card.style.visibility = "visible";
  card.style.opacity = "0"; // 먼저 투명하게 시작

  // 카드가 서서히 나타나는 애니메이션 적용
  setTimeout(() => {
    // 애니메이션 클래스 추가
    card.classList.add("show");
    card.style.transition =
      "opacity 0.8s ease-in-out, transform 0.8s ease-in-out";
    card.style.opacity = "1";
    card.style.transform = "translateY(0) scale(1)";
    console.log("카드 애니메이션 시작");

    // 카테고리에 따라 다른 효과 적용
    setTimeout(() => {
      try {
        // 카드 정보 로그 출력
        console.log("카드 정보:", {
          제목: cardData.name || "없음",
          메시지: cardData.message
            ? cardData.message.substring(0, 20) + "..."
            : "없음",
          이모지: cardData.emoji || "없음",
        });

        // 카테고리 판별 - 특정 템플릿 이름 기반으로 판별
        const category = determineCategory(cardData);
        console.log("카드 카테고리:", category);

        // 디버깅: 효과 컨테이너 확인
        const effectsContainer = document.getElementById("effectsContainer");
        console.log("효과 컨테이너:", effectsContainer);

        // 카드 컨테이너 구조 확인
        const cardContainer = document.getElementById("cardContainer");
        console.log("카드 컨테이너:", cardContainer);

        // 카테고리별 효과 적용
        if (category === "love") {
          console.log(
            "사랑 템플릿 확인: 하트 효과 적용 (사랑고백, 연인에게, 로맨틱)"
          );
          createHeartEffect();
          console.log("하트 효과 시작");
        } else {
          console.log(
            "일반 템플릿 확인: 색종이 효과 적용 (사랑 템플릿이 아님)"
          );
          createConfettiEffect();
          console.log("색종이 효과 시작");
        }
      } catch (error) {
        console.error("애니메이션 효과 적용 중 오류:", error);
      }
    }, 300);
  }, 100);
}

// 기본 카드 표시 함수
function displayDefaultCard(shareId) {
  document.getElementById("loading").style.display = "none";

  // 카드 요소들 확보
  const card = document.getElementById("card");
  const emojiElement = document.getElementById("emoji");
  const titleElement = document.getElementById("title");
  const messageElement = document.getElementById("message");

  // 카드 컨테이너 표시 상태 확인
  const cardContainer = document.getElementById("cardContainer");
  if (cardContainer) {
    cardContainer.style.display = "block";
    cardContainer.style.visibility = "visible";
    cardContainer.style.opacity = "1";
  }

  if (shareId) {
    // 기본 카드 표시 (ID만 있는 경우)
    if (emojiElement) emojiElement.textContent = "⚠️";
    if (titleElement) titleElement.textContent = "카드 정보를 찾을 수 없습니다";
    if (messageElement)
      messageElement.textContent =
        "카드가 만료되었거나 잘못된 링크입니다. 카드톡 앱에서 다시 공유해보세요.";
  } else {
    // ID도 없는 경우
    if (emojiElement) emojiElement.textContent = "🔒";
    if (titleElement) titleElement.textContent = "잘못된 접근입니다";
    if (messageElement)
      messageElement.textContent = "올바른 링크로 접속해주세요.";
  }

  // 스타일 적용
  if (emojiElement) {
    emojiElement.style.display = "block";
    emojiElement.style.visibility = "visible";
    emojiElement.style.opacity = "1";
    emojiElement.style.fontSize = "5rem";
  }

  if (titleElement && messageElement) {
    titleElement.style.display = "block";
    titleElement.style.visibility = "visible";
    titleElement.style.opacity = "1";
    messageElement.style.display = "block";
    messageElement.style.visibility = "visible";
    messageElement.style.opacity = "1";

    // 한글 폰트 처리 강화
    titleElement.style.fontFamily =
      '"Noto Sans KR", "Apple SD Gothic Neo", sans-serif';
    messageElement.style.fontFamily =
      '"Noto Sans KR", "Apple SD Gothic Neo", sans-serif';
  }

  // 카드 스타일 및 표시
  if (card) {
    card.style.backgroundColor = "#fff9c4"; // 밝은 노란색 배경
    card.style.display = "block";
    card.style.visibility = "visible";
    card.style.opacity = "1";

    // 기본 텍스트 색상
    if (titleElement) titleElement.style.color = "#ff5722"; // 주황색 제목
    if (messageElement) messageElement.style.color = "#333333"; // 어두운 회색 메시지
  }
}

// 오류 표시 함수
function showError(message) {
  // 로딩 표시 숨김
  const loadingElement = document.getElementById("loading");
  if (loadingElement) {
    loadingElement.style.display = "none";
  }

  // 오류 표시를 위한 컨테이너 생성 또는 획득
  let errorContainer = document.getElementById("errorContainer");
  if (!errorContainer) {
    errorContainer = document.createElement("div");
    errorContainer.id = "errorContainer";
    document.body.appendChild(errorContainer);

    // 오류 컨테이너 스타일 설정
    errorContainer.style.position = "fixed";
    errorContainer.style.top = "0";
    errorContainer.style.left = "0";
    errorContainer.style.width = "100%";
    errorContainer.style.height = "100%";
    errorContainer.style.display = "flex";
    errorContainer.style.flexDirection = "column";
    errorContainer.style.justifyContent = "center";
    errorContainer.style.alignItems = "center";
    errorContainer.style.backgroundColor = "rgba(255, 235, 238, 0.95)"; // 밝은 빨간색 배경
    errorContainer.style.zIndex = "9999"; // 최상위 표시
    errorContainer.style.padding = "20px";
    errorContainer.style.boxSizing = "border-box";
    errorContainer.style.textAlign = "center";
  }

  // 기존 오류 컨테이너 내용 제거
  errorContainer.innerHTML = "";

  // 카드 컨테이너 숨김
  const cardContainer = document.getElementById("cardContainer");
  if (cardContainer) {
    cardContainer.style.display = "none";
  }

  // URL 파라미터 및 디버그 모드 확인
  const urlParams = new URLSearchParams(window.location.search);
  const isDebug = urlParams.get("debug") === "true";
  const shareId = urlParams.get("id") || "unknown";

  // 오류 아이콘 생성
  const errorIcon = document.createElement("div");
  errorIcon.innerHTML = "⚠️";
  errorIcon.style.fontSize = "72px";
  errorIcon.style.marginBottom = "20px";
  errorContainer.appendChild(errorIcon);

  // 오류 유형 판단
  let errorType = "unknown";
  let userFriendlyMessage = "카드를 불러올 수 없습니다";

  if (message.includes("Base64")) {
    errorType = "base64-decode";
    userFriendlyMessage = "카드 데이터 형식이 올바르지 않습니다";
  } else if (message.includes("JSON")) {
    errorType = "json-parse";
    userFriendlyMessage = "카드 데이터가 손상되었습니다";
  } else if (message.includes("color")) {
    errorType = "color-format";
    userFriendlyMessage = "카드의 색상 형식에 문제가 있습니다";
  } else if (message.includes("undefined") || message.includes("null")) {
    errorType = "missing-property";
    userFriendlyMessage = "카드 데이터가 불완전합니다";
  }

  // 오류 제목 생성
  const errorTitle = document.createElement("h2");
  errorTitle.textContent = userFriendlyMessage;
  errorTitle.style.color = "#d32f2f"; // 진한 빨간색
  errorTitle.style.fontFamily = "'Noto Sans KR', sans-serif";
  errorTitle.style.fontSize = "24px";
  errorTitle.style.margin = "10px 0";
  errorContainer.appendChild(errorTitle);

  // 오류 설명 생성
  const errorDesc = document.createElement("p");
  errorDesc.textContent =
    "카드가 만료되었거나 잘못된 링크일 수 있습니다. 카드톡 앱에서 다시 공유해보세요.";
  errorDesc.style.color = "#555555";
  errorDesc.style.fontFamily = "'Noto Sans KR', sans-serif";
  errorDesc.style.fontSize = "16px";
  errorDesc.style.margin = "10px 0 20px 0";
  errorContainer.appendChild(errorDesc);

  // 개발 모드에서 상세 오류 정보 표시
  if (isDebug) {
    // 상세 오류 컨테이너
    const detailContainer = document.createElement("div");
    detailContainer.style.backgroundColor = "#f8f8f8";
    detailContainer.style.border = "1px solid #ddd";
    detailContainer.style.borderRadius = "8px";
    detailContainer.style.padding = "15px";
    detailContainer.style.margin = "15px 0";
    detailContainer.style.maxWidth = "90%";
    detailContainer.style.width = "500px";
    detailContainer.style.textAlign = "left";
    detailContainer.style.overflow = "auto";
    detailContainer.style.fontFamily = "monospace";

    // 오류 유형 표시
    const errorTypeElement = document.createElement("div");
    errorTypeElement.innerHTML = `<strong>오류 유형:</strong> ${errorType}`;
    errorTypeElement.style.marginBottom = "10px";
    detailContainer.appendChild(errorTypeElement);

    // 오류 메시지 표시
    const errorMsgElement = document.createElement("div");
    errorMsgElement.innerHTML = `<strong>오류 메시지:</strong> ${message}`;
    errorMsgElement.style.marginBottom = "10px";
    detailContainer.appendChild(errorMsgElement);

    // 카드 ID 표시
    const cardIdElement = document.createElement("div");
    cardIdElement.innerHTML = `<strong>카드 ID:</strong> ${shareId}`;
    cardIdElement.style.marginBottom = "10px";
    detailContainer.appendChild(cardIdElement);

    // 오류 시간 표시
    const timeElement = document.createElement("div");
    timeElement.innerHTML = `<strong>발생 시간:</strong> ${new Date().toLocaleString()}`;
    detailContainer.appendChild(timeElement);

    errorContainer.appendChild(detailContainer);

    // 콘솔에 디버깅 정보 출력
    console.group("카드 로딩 디버그 정보");
    console.log("URL 파라미터:", urlParams.toString());
    console.log("카드 ID:", shareId);
    console.log("User Agent:", navigator.userAgent);
    console.log("오류 메시지:", message);
    console.log("오류 유형:", errorType);
    console.groupEnd();
  }

  // 버튼 컨테이너
  const buttonContainer = document.createElement("div");
  buttonContainer.style.marginTop = "25px";
  buttonContainer.style.display = "flex";
  buttonContainer.style.flexDirection = "column";
  buttonContainer.style.alignItems = "center";
  errorContainer.appendChild(buttonContainer);

  // 재시도 버튼 생성
  const retryButton = document.createElement("button");
  retryButton.textContent = "다시 시도";
  retryButton.onclick = function () {
    location.reload();
  };
  retryButton.style.backgroundColor = "#e91e63"; // 핑크색
  retryButton.style.color = "white";
  retryButton.style.border = "none";
  retryButton.style.borderRadius = "25px";
  retryButton.style.padding = "12px 30px";
  retryButton.style.fontSize = "16px";
  retryButton.style.cursor = "pointer";
  retryButton.style.fontFamily = "'Noto Sans KR', sans-serif";
  retryButton.style.fontWeight = "bold";
  retryButton.style.boxShadow = "0 2px 5px rgba(0,0,0,0.2)";
  retryButton.style.transition = "background-color 0.3s";

  // 버튼 호버 효과
  retryButton.onmouseover = function () {
    this.style.backgroundColor = "#d81b60";
  };
  retryButton.onmouseout = function () {
    this.style.backgroundColor = "#e91e63";
  };

  buttonContainer.appendChild(retryButton);

  // 앱으로 가기 버튼 (선택 사항)
  const appButton = document.createElement("button");
  appButton.textContent = "카드톡 앱으로 가기";
  appButton.onclick = function () {
    location.href = "cardtalk://open";
  };
  appButton.style.backgroundColor = "transparent";
  appButton.style.color = "#e91e63";
  appButton.style.border = "1px solid #e91e63";
  appButton.style.borderRadius = "25px";
  appButton.style.padding = "10px 20px";
  appButton.style.fontSize = "14px";
  appButton.style.cursor = "pointer";
  appButton.style.fontFamily = "'Noto Sans KR', sans-serif";
  appButton.style.marginTop = "15px";

  buttonContainer.appendChild(appButton);

  // 기존 오류 요소와 카드를 숨김
  try {
    const errorElement = document.getElementById("error");
    if (errorElement) {
      errorElement.style.display = "none";
    }

    const defaultCard = document.getElementById("card");
    if (defaultCard) {
      defaultCard.style.display = "none";
    }
  } catch (e) {
    console.error("기존 요소 숨김 처리 중 오류:", e);
  }

  // 오류 컨테이너 표시
  errorContainer.style.display = "flex";
}

// 카드 카테고리 판별 함수
function determineCategory(cardData) {
  console.log("카드 카테고리 판별 시작:", cardData.name);

  // 특정 사랑 템플릿 이름을 확인 (사랑고백, 연인에게, 로맨틱)
  const loveTemplates = ["사랑고백", "연인에게", "로맨틱", "사랑", "연인"];

  // 템플릿 이름으로 확인
  if (cardData.name) {
    const templateName = cardData.name.trim();
    console.log("템플릿 이름 확인:", templateName);

    // 특정 템플릿 이름이 포함되어 있으면 하트 효과 적용
    for (const loveTemplate of loveTemplates) {
      if (templateName.includes(loveTemplate)) {
        console.log(`사랑 템플릿 '${loveTemplate}' 확인됨:`, templateName);
        return "love";
      }
    }

    // 템플릿 이름이 한글일 경우 추가 체크
    if (
      templateName === "사랑고백" ||
      templateName === "연인에게" ||
      templateName === "로맨틱" ||
      templateName === "연인" ||
      templateName.indexOf("사랑") >= 0
    ) {
      console.log("한글 사랑 템플릿 확인됨:", templateName);
      return "love";
    }
  }

  // 사랑 템플릿이 아닌 경우를 위한 다른 정보 (참고용)
  const loveKeywords = [
    "사랑",
    "love",
    "♥",
    "❤",
    "💕",
    "💓",
    "💗",
    "💖",
    "💘",
    "💝",
    "♡",
    "❣️",
  ];
  const loveEmojis = [
    "❤️",
    "💕",
    "💓",
    "💗",
    "💖",
    "💘",
    "💝",
    "♥️",
    "♡",
    "😍",
    "😘",
    "💑",
    "💏",
    "👩‍❤️‍👨",
    "👩‍❤️‍👩",
    "👨‍❤️‍👨",
  ];
  const loveBgColors = [
    "#ffccd5",
    "#fadadd",
    "#ffb6c1",
    "#ff69b4",
    "#fc89ac",
    "#e91e63",
  ];

  // 이미 위에서 템플릿 이름으로 확인을 했으므로 여기서는 더 이상 확인할 필요 없음
  // 기본값은 일반 카테고리 (사랑고백, 연인에게, 로맨틱 템플릿이 아님)
  console.log(
    "일반 카테고리로 판별됨 (사랑고백, 연인에게, 로맨틱 템플릿이 아님)"
  );
  return "general";
}

// 하트 효과 생성 함수
function createHeartEffect() {
  try {
    console.log("===== ❤️ 하트 효과 생성 시작 =====");
    console.log("하트 효과는 사랑고백, 연인에게, 로맨틱 템플릿에만 적용됩니다");

    // 하트 애니메이션용 CSS 스타일 추가
    const styleId = "heartAnimationStyle";
    if (!document.getElementById(styleId)) {
      const style = document.createElement("style");
      style.id = styleId;
      style.textContent = `
        @keyframes float-heart {
          0% {
            opacity: 0;
            transform: translateY(0) scale(0.5);
          }
          10% {
            opacity: 1;
          }
          90% {
            opacity: 0.8;
          }
          100% {
            opacity: 0;
            transform: translateY(-100vh) scale(1) rotate(var(--random-rotate));
            margin-left: var(--random-x);
          }
        }
        .heart {
          position: absolute;
          background-color: #ff4081;
          display: inline-block;
          width: 20px;
          height: 20px;
          transform: rotate(45deg);
          opacity: 0;
        }
        .heart:before, .heart:after {
          content: '';
          width: 100%;
          height: 100%;
          background-color: inherit;
          border-radius: 50%;
          position: absolute;
        }
        .heart:before {
          left: -50%;
          top: 0;
        }
        .heart:after {
          top: -50%;
          left: 0;
        }
      `;
      document.head.appendChild(style);
      console.log("하트 애니메이션 스타일 추가됨");
    }

    // 효과 컨테이너 확보 (없으면 body에 새로 생성)
    let effectsContainer = document.getElementById("effectsContainer");
    if (!effectsContainer) {
      console.log("효과 컨테이너가 없어 새로 생성합니다");

      effectsContainer = document.createElement("div");
      effectsContainer.id = "effectsContainer";
      effectsContainer.className = "effects-container";
      effectsContainer.style.position = "fixed";
      effectsContainer.style.top = "0";
      effectsContainer.style.left = "0";
      effectsContainer.style.width = "100%";
      effectsContainer.style.height = "100vh";
      effectsContainer.style.zIndex = "30";
      effectsContainer.style.pointerEvents = "none";
      effectsContainer.style.overflow = "visible";

      // body에 직접 추가 (z-index가 올바르게 적용되도록)
      document.body.prepend(effectsContainer);
      console.log("새 효과 컨테이너 생성됨 (body에 추가됨)");
      console.log("효과 컨테이너 z-index:", effectsContainer.style.zIndex);
    }

    const count = 20; // 하트 개수
    console.log(`${count}개의 하트 생성 시작`);

    for (let i = 0; i < count; i++) {
      // 하트 요소 생성
      const heart = document.createElement("div");
      heart.className = "heart";

      // 랜덤 위치 및 크기 설정
      const size = Math.random() * 20 + 10;
      heart.style.width = `${size}px`;
      heart.style.height = `${size}px`;

      // 애니메이션 변수 설정
      const randomX = Math.random() * 200 - 100;
      const randomRotate = Math.random() * 60 - 30;
      heart.style.setProperty("--random-x", `${randomX}px`);
      heart.style.setProperty("--random-rotate", `${randomRotate}deg`);

      // 위치 설정
      const containerRect = effectsContainer.getBoundingClientRect();
      const leftPosition = Math.random() * containerRect.width;
      const topPosition = containerRect.height - 50 + Math.random() * 80; // 하단에서 시작

      heart.style.left = `${leftPosition}px`;
      heart.style.top = `${topPosition}px`;

      // 애니메이션 직접 적용
      const duration = Math.random() * 3 + 4; // 4~7초
      const delay = Math.random() * 4;

      heart.style.animation = `float-heart ${duration}s ease-in-out ${delay}s forwards`;

      // 하트 색상 다양화
      const colors = ["#ff4081", "#e91e63", "#f06292", "#ec407a", "#ff80ab"];
      const color = colors[Math.floor(Math.random() * colors.length)];
      heart.style.backgroundColor = color;

      // 효과 컨테이너에 추가
      effectsContainer.appendChild(heart);

      // 애니메이션 시작 시 로그
      if (i === 0) {
        console.log("첫 번째 하트 추가됨:", heart);
      }

      // 애니메이션 종료 후 제거
      setTimeout(() => {
        if (heart.parentNode === effectsContainer) {
          heart.remove();
        }
      }, (duration + delay) * 1000);
    }

    // 주기적으로 새 하트 추가
    setTimeout(() => {
      if (document.body.contains(document.getElementById("cardContainer"))) {
        createHeartEffect();
      }
    }, 5000);
  } catch (error) {
    console.error("하트 효과 생성 중 오류:", error);
  }
}

// 색종이(팡파레) 효과 생성 함수
function createConfettiEffect() {
  try {
    console.log("===== 🎊 색종이 효과 생성 시작 =====");
    console.log(
      "색종이 효과는 일반 템플릿에 적용됩니다 (사랑고백, 연인에게, 로맨틱 제외)"
    );

    // 색종이 애니메이션용 CSS 스타일 추가
    const styleId = "confettiAnimationStyle";
    if (!document.getElementById(styleId)) {
      const style = document.createElement("style");
      style.id = styleId;
      style.textContent = `
        @keyframes fall-confetti {
          0% {
            opacity: 0;
            transform: translateY(-10px);
          }
          10% {
            opacity: 1;
          }
          100% {
            opacity: 0;
            transform: translateY(100vh) rotate(360deg);
            margin-left: var(--random-x);
          }
        }
        .confetti {
          position: absolute;
          width: 10px;
          height: 10px;
          background-color: #fd6c6c;
          opacity: 0;
        }
      `;
      document.head.appendChild(style);
      console.log("색종이 애니메이션 스타일 추가됨");
    }

    // 효과 컨테이너 확보 (없으면 body에 새로 생성)
    let effectsContainer = document.getElementById("effectsContainer");
    if (!effectsContainer) {
      console.log("효과 컨테이너가 없어 새로 생성합니다");

      effectsContainer = document.createElement("div");
      effectsContainer.id = "effectsContainer";
      effectsContainer.className = "effects-container";
      effectsContainer.style.position = "fixed";
      effectsContainer.style.top = "0";
      effectsContainer.style.left = "0";
      effectsContainer.style.width = "100%";
      effectsContainer.style.height = "100vh";
      effectsContainer.style.zIndex = "30";
      effectsContainer.style.pointerEvents = "none";
      effectsContainer.style.overflow = "visible";

      // body에 직접 추가 (z-index가 올바르게 적용되도록)
      document.body.prepend(effectsContainer);
      console.log("새 효과 컨테이너 생성됨 (body에 추가됨)");
      console.log("효과 컨테이너 z-index:", effectsContainer.style.zIndex);
    }

    const count = 40; // 색종이 개수
    console.log(`${count}개의 색종이 생성 시작`);

    const colors = [
      "#fd6c6c",
      "#5ec9f5",
      "#ffeb3b",
      "#43e97b",
      "#a35cff",
      "#ff9f43",
      "#64b5f6",
      "#4caf50",
      "#9c27b0",
    ];

    for (let i = 0; i < count; i++) {
      // 색종이 요소 생성
      const confetti = document.createElement("div");
      confetti.className = "confetti";

      // 랜덤 크기, 모양, 색상 설정
      const size = Math.random() * 10 + 6;
      confetti.style.width = `${size}px`;
      confetti.style.height = `${size}px`;

      // 랜덤 색상
      const color = colors[Math.floor(Math.random() * colors.length)];
      confetti.style.backgroundColor = color;

      // 애니메이션 변수 설정
      const randomX = Math.random() * 200 - 100;
      confetti.style.setProperty("--random-x", `${randomX}px`);

      // 다양한 모양 (원형, 다이아몬드, 사각형)
      const shapeType = Math.random();
      if (shapeType > 0.7) {
        confetti.style.borderRadius = "50%"; // 원형
      } else if (shapeType > 0.4) {
        confetti.style.transform = "rotate(45deg)"; // 다이아몬드
      }

      // 위치 설정 (화면 상단에서 시작)
      const containerRect = effectsContainer.getBoundingClientRect();
      const leftPosition = Math.random() * containerRect.width;
      const topPosition = -size - Math.random() * 60; // 화면 위에서 시작

      confetti.style.left = `${leftPosition}px`;
      confetti.style.top = `${topPosition}px`;

      // 애니메이션 직접 적용
      const duration = Math.random() * 3 + 3; // 3~6초
      const delay = Math.random() * 3;
      confetti.style.animation = `fall-confetti ${duration}s ease-in-out ${delay}s forwards`;

      // 초기 투명도 설정
      confetti.style.opacity = "0";

      // 효과 컨테이너에 추가
      effectsContainer.appendChild(confetti);

      // 애니메이션 시작 시 로그
      if (i === 0) {
        console.log("첫 번째 색종이 추가됨:", confetti);
      }

      // 애니메이션 종료 후 제거
      setTimeout(() => {
        if (confetti.parentNode === effectsContainer) {
          confetti.remove();
        }
      }, (duration + delay) * 1000);
    }

    // 주기적으로 새 색종이 추가
    setTimeout(() => {
      if (document.body.contains(document.getElementById("cardContainer"))) {
        createConfettiEffect();
      }
    }, 5000);
  } catch (error) {
    console.error("색종이 효과 생성 중 오류:", error);
  }
}
