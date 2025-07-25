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

        // 3. Base64 → Uint8Array (바이너리) - 에러 처리 개선
        function base64ToUint8Array(base64) {
          try {
            // Base64 문자열 유효성 검사
            if (!/^[A-Za-z0-9+/]*={0,2}$/.test(base64)) {
              throw new Error("유효하지 않은 Base64 문자열입니다.");
            }

            const binaryString = atob(base64);
            const len = binaryString.length;
            const bytes = new Uint8Array(len);
            for (let i = 0; i < len; i++) {
              bytes[i] = binaryString.charCodeAt(i);
            }
            return bytes;
          } catch (error) {
            console.error("Base64 디코딩 오류:", error);
            throw new Error("Base64 디코딩에 실패했습니다: " + error.message);
          }
        }

        const bytes = base64ToUint8Array(base64Data);
        const jsonData = new TextDecoder("utf-8").decode(bytes);
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
            console.error("모든 파싱 방법 실패");
            throw new Error(
              `JSON 파싱 실패. cleanJson: "${cleanJson}", jsonData: "${jsonData}"`
            );
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

  // 카드 데이터 설정
  if (cardData.emoji) {
    document.getElementById("emoji").textContent = cardData.emoji;
  }
  if (cardData.name) {
    document.getElementById("title").textContent = cardData.name;
  }
  if (cardData.message) {
    document.getElementById("message").textContent = cardData.message;
  }

  // 배경색 및 텍스트 색상 설정
  if (cardData.backgroundColor) {
    card.style.backgroundColor = cardData.backgroundColor;
  }
  if (cardData.textColor) {
    card.style.color = cardData.textColor;
  }

  // 카드 표시
  card.style.display = "block";
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
