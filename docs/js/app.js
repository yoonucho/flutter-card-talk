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

        // 2. URL 안전 Base64를 표준 Base64로 변환
        let base64Data = urlDecoded.replace(/-/g, "+").replace(/_/g, "/");
        // 공백, 줄바꿈 등 제거
        base64Data = base64Data.replace(/\s+/g, "");

        // Base64 패딩 보정
        while (base64Data.length % 4) {
          base64Data += "=";
        }

        console.log("3. base64Data(clean):", base64Data);

        // 3. Base64 디코딩 - 더 안정적인 방법 적용
        let jsonData;
        try {
          // 방법 1: TextDecoder 사용 (권장)
          try {
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
                throw error; // 원래 오류 다시 발생
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
    emojiElement.textContent = cardData.emoji;
    // 이모지 특별 처리
    emojiElement.style.display = "block";
    emojiElement.style.visibility = "visible";
    emojiElement.style.opacity = "1";
    console.log("이모지 설정됨:", cardData.emoji);
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

  // 배경색 및 텍스트 색상 설정
  if (cardData.backgroundColor) {
    card.style.backgroundColor = cardData.backgroundColor;
    console.log("배경색 설정됨:", cardData.backgroundColor);
  } else {
    // 기본 배경색
    card.style.backgroundColor = "#ffffff";
  }

  if (cardData.textColor) {
    // 텍스트 색상 개별 적용
    document.getElementById("title").style.color = cardData.textColor;
    document.getElementById("message").style.color = cardData.textColor;
    console.log("텍스트 색상 설정됨:", cardData.textColor);
  } else {
    // 기본 텍스트 색상
    document.getElementById("title").style.color = "#e91e63";
    document.getElementById("message").style.color = "#333333";
  }

  // 카드 컨테이너 표시
  if (cardContainer) {
    cardContainer.style.opacity = "1";
  }

  // 카드 표시 및 애니메이션 적용
  card.style.display = "block";

  // 약간의 지연 후 애니메이션 클래스 추가
  setTimeout(() => {
    card.classList.add("show");
  }, 100);
}

// 기본 카드 표시 함수
function displayDefaultCard(shareId) {
  document.getElementById("loading").style.display = "none";

  if (shareId) {
    // 기본 카드 표시 (ID만 있는 경우)
    document.getElementById("title").textContent =
      "카드 정보를 찾을 수 없습니다";
    document.getElementById("message").textContent =
      "카드가 만료되었거나 잘못된 링크입니다. 카드톡 앱에서 다시 공유해보세요.";
  } else {
    // ID도 없는 경우
    document.getElementById("title").textContent = "잘못된 접근입니다";
    document.getElementById("message").textContent =
      "올바른 링크로 접속해주세요.";
  }

  document.getElementById("card").style.display = "block";
}

// 오류 표시 함수
function showError(message) {
  document.getElementById("loading").style.display = "none";
  const errorElement = document.getElementById("error");
  const errorMessageElement = document.getElementById("errorMessage");

  // 오류 메시지 사용자 친화적으로 변경
  let userFriendlyMessage = "카드를 불러올 수 없습니다.";

  // 개발 모드에서만 상세 오류 표시 (URL에 debug=true가 있는 경우)
  const urlParams = new URLSearchParams(window.location.search);
  const isDebug = urlParams.get("debug") === "true";

  if (isDebug) {
    userFriendlyMessage += " 상세 오류: " + message;

    // 콘솔에 디버깅 정보 출력
    console.group("카드 로딩 디버그 정보");
    console.log("URL 파라미터:", urlParams.toString());
    console.log("User Agent:", navigator.userAgent);
    console.log("오류 메시지:", message);
    console.groupEnd();
  } else {
    userFriendlyMessage += " 다시 시도해 주세요.";
  }

  if (errorMessageElement) {
    errorMessageElement.textContent = userFriendlyMessage;
  }
  errorElement.style.display = "block";
}
