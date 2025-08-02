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
  // 인트로 애니메이션 시작
  setTimeout(() => {
    const introText = document.getElementById("introText");
    const introSubtext = document.getElementById("introSubtext");
    const introButton = document.getElementById("introButton");

    if (introText) introText.classList.add("show");

    setTimeout(() => {
      if (introSubtext) introSubtext.classList.add("show");
    }, 300);

    setTimeout(() => {
      if (introButton) introButton.classList.add("show");
    }, 600);
  }, 200);

  // 인트로 화면 설정
  const introButton = document.getElementById("introButton");
  if (introButton) {
    introButton.addEventListener("click", function () {
      const intro = document.getElementById("intro");
      const cardContainer = document.getElementById("cardContainer");

      intro.style.display = "none";
      cardContainer.style.display = "block";

      // 카드 컨테이너 애니메이션 시작
      setTimeout(() => {
        cardContainer.classList.add("show");
      }, 100);

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

  // CSS 애니메이션 시작
  setTimeout(() => {
    const titleElement = document.querySelector(".container > .title");
    const messageElement = document.querySelector(".container > .message");

    if (titleElement) {
      setTimeout(() => titleElement.classList.add("show"), 100);
    }

    if (messageElement) {
      setTimeout(() => messageElement.classList.add("show"), 300);
    }

    // 버튼들도 애니메이션 효과 추가
    const buttons = document.querySelectorAll(".button");
    buttons.forEach((button, index) => {
      setTimeout(() => button.classList.add("show"), 500 + index * 200);
    });
  }, 200);
}

// 기본 페이지 설정
function setupDefaultPage() {
  console.log("기본 페이지 로드");
}

// 카드 데이터 가져오기 함수
function loadCardData(shareId) {
  // URL 파라미터에서 카드 데이터 가져오기
  const urlParams = new URLSearchParams(window.location.search);
  const encodedData = urlParams.get("data");

  console.log("인코딩된 데이터:", encodedData);

  if (encodedData && encodedData.trim() !== "") {
    try {
      const cardData = decodeCardData(encodedData);
      displayCard(cardData);
    } catch (error) {
      console.error("카드 데이터 처리 오류:", error);
      displayDefaultCard(shareId);
    }
  } else {
    console.log("인코딩된 데이터가 없음");
    displayDefaultCard(shareId);
  }
}

// Base64 디코딩 및 JSON 파싱 처리 (단일 책임 원칙)
function decodeCardData(encodedData) {
  // URL 디코딩 시도
  const urlDecoded = tryUrlDecode(encodedData);

  // Base64 디코딩 시도
  const base64Data = normalizeBase64(urlDecoded);

  // UTF-8 바이트 배열로 디코딩
  const jsonString = decodeBase64ToUtf8(base64Data);

  // JSON 파싱
  return parseJsonSafely(jsonString);
}

// URL 디코딩 처리
function tryUrlDecode(data) {
  try {
    return decodeURIComponent(data);
  } catch (error) {
    console.warn("URL 디코딩 실패, 원본 데이터 사용:", error);
    return data;
  }
}

// Base64 정규화 (URL-safe → 표준)
function normalizeBase64(data) {
  let base64String = data.replace(/-/g, "+").replace(/_/g, "/");

  // 패딩 추가
  while (base64String.length % 4) {
    base64String += "=";
  }

  return base64String;
}

// Base64를 UTF-8 문자열로 디코딩 (오류 내성 강화)
function decodeBase64ToUtf8(base64String) {
  try {
    // 1차 시도: 표준 방식
    const result = decodeBase64Standard(base64String);
    if (result) return result;
  } catch (error) {
    console.warn("표준 Base64 디코딩 실패:", error);
  }

  try {
    // 2차 시도: 부분 디코딩
    return decodeBase64Partial(base64String);
  } catch (error) {
    console.error("Base64 디코딩 완전 실패:", error);
    throw new Error(`Base64 디코딩 실패: ${error.message}`);
  }
}

// 표준 Base64 디코딩
function decodeBase64Standard(base64String) {
  // Base64 → 바이너리 문자열
  const binaryString = atob(base64String);

  // 바이너리 문자열 → Uint8Array
  const bytes = new Uint8Array(binaryString.length);
  for (let i = 0; i < binaryString.length; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }

  // UTF-8 디코딩
  const decoder = new TextDecoder("utf-8");
  return decoder.decode(bytes);
}

// 부분 Base64 디코딩 (오류 내성)
function decodeBase64Partial(base64String) {
  console.log("부분 Base64 디코딩 시작");

  // Base64 문자열을 조금씩 줄여가며 디코딩 시도
  for (let len = base64String.length; len > 10; len -= 4) {
    try {
      const partialBase64 = base64String.substring(0, len);

      // 패딩 정규화
      let normalizedBase64 = partialBase64;
      while (normalizedBase64.length % 4) {
        normalizedBase64 += "=";
      }

      const result = decodeBase64Standard(normalizedBase64);

      // 최소한 JSON 시작 부분이 있는지 확인
      if (result && result.includes('{"')) {
        console.log(`부분 디코딩 성공 (길이: ${len}/${base64String.length})`);
        return result;
      }
    } catch (error) {
      // 이 길이로는 실패, 더 짧게 시도
      continue;
    }
  }

  throw new Error("부분 디코딩도 실패");
}

// 안전한 JSON 파싱 (부분 복구 지원)
function parseJsonSafely(jsonString) {
  try {
    console.log("파싱할 JSON 문자열:", jsonString);

    // 1단계: 정상 JSON 파싱 시도
    const cleanedJson = cleanJsonString(jsonString);
    console.log("정리된 JSON 문자열:", cleanedJson);

    try {
      const cardData = JSON.parse(cleanedJson);
      console.log("파싱된 카드 데이터:", cardData);
      validateCardData(cardData);
      return cardData;
    } catch (parseError) {
      console.warn("정상 JSON 파싱 실패, 부분 복구 시도:", parseError);

      // 2단계: 부분 복구 시스템
      return parsePartialJson(jsonString);
    }
  } catch (error) {
    console.error("JSON 파싱 완전 실패:", error);
    throw new Error(`JSON 파싱 실패: ${error.message}`);
  }
}

// 부분 JSON 복구 시스템 (정규식 기반 필드 추출)
function parsePartialJson(jsonString) {
  console.log("부분 복구 시스템 시작");
  console.log("전체 JSON 문자열 길이:", jsonString.length);
  console.log("JSON 문자열 앞 100자:", jsonString.substring(0, 100));
  console.log(
    "JSON 문자열 뒤 100자:",
    jsonString.substring(Math.max(0, jsonString.length - 100))
  );

  const cardData = {};

  try {
    // name 필드 추출
    const nameMatch = jsonString.match(/"name"\s*:\s*"([^"]*?)"/);
    if (nameMatch) {
      cardData.name = nameMatch[1];
      console.log("name 복구:", cardData.name);
    }

    // emoji 필드 추출 (이모지는 특수문자 포함)
    const emojiMatch = jsonString.match(/"emoji"\s*:\s*"([^"]*?)"/);
    if (emojiMatch) {
      cardData.emoji = emojiMatch[1];
      console.log("emoji 복구:", cardData.emoji);
    }

    // message 필드 추출 (깨진 문자 전까지만)
    const messageMatch = jsonString.match(/"message"\s*:\s*"([^"]*)/);
    if (messageMatch) {
      let message = messageMatch[1];

      // 유니코드 제어 문자나 깨진 문자가 시작되는 지점 찾기
      const corruptIndex = message.search(
        /[\u0000-\u001F\u007F-\u009F\u2000-\u200F\u202A-\u202E\u2060-\u206F\uFEFF\uD800-\uDFFF]|[��]|[\uFFFD]/
      );

      if (corruptIndex !== -1) {
        // 깨진 문자 전까지만 자르기
        message = message.substring(0, corruptIndex);
        console.log(`깨진 문자 감지, ${corruptIndex} 위치에서 자름`);
      }

      // 추가로 한글/영문/숫자/기본 특수문자만 유지 (더 엄격한 필터링)
      message = message.replace(
        /[^\uAC00-\uD7AF\u1100-\u11FF\u3130-\u318F\u0020-\u007E\u00A0-\u00FF\u2600-\u27BF\uD83C-\uDBFF\uDC00-\uDFFF!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/g,
        ""
      );

      cardData.message = message.trim();
      console.log("message 복구:", cardData.message);
    }

    // backgroundColor 필드 추출 시도 (다양한 패턴 시도)
    console.log("backgroundColor 검색 시작...");

    // 패턴 1: 표준 형식
    let bgColorMatch = jsonString.match(/"backgroundColor"\s*:\s*"([^"]*?)"/);
    console.log("패턴 1 결과:", bgColorMatch);

    // 패턴 2: 따옴표 없이 끝나는 경우
    if (!bgColorMatch) {
      bgColorMatch = jsonString.match(/"backgroundColor"\s*:\s*"([^",}]*)/);
      console.log("패턴 2 결과:", bgColorMatch);
    }

    // 패턴 3: 잘못된 형식 감지 ("# [색상값" 형태)
    if (!bgColorMatch) {
      bgColorMatch = jsonString.match(/"backgroundColor"\s*:\s*"([^"]*)/);
      console.log("패턴 3 결과:", bgColorMatch);
    }

    if (bgColorMatch) {
      console.log("backgroundColor 원본:", bgColorMatch[1]);
      const color = sanitizeColor(bgColorMatch[1]);
      if (color) {
        cardData.backgroundColor = color;
        console.log("backgroundColor 복구:", cardData.backgroundColor);
      } else {
        console.log("backgroundColor 정리 실패");
      }
    } else {
      console.log("backgroundColor 패턴 매칭 실패");
    }

    // textColor 필드 추출 시도 (다양한 패턴 시도)
    console.log("textColor 검색 시작...");

    // 패턴 1: 표준 형식
    let textColorMatch = jsonString.match(/"textColor"\s*:\s*"([^"]*?)"/);
    console.log("패턴 1 결과:", textColorMatch);

    // 패턴 2: 따옴표 없이 끝나는 경우
    if (!textColorMatch) {
      textColorMatch = jsonString.match(/"textColor"\s*:\s*"([^",}]*)/);
      console.log("패턴 2 결과:", textColorMatch);
    }

    // 패턴 3: 잘못된 형식 감지
    if (!textColorMatch) {
      textColorMatch = jsonString.match(/"textColor"\s*:\s*"([^"]*)/);
      console.log("패턴 3 결과:", textColorMatch);
    }

    if (textColorMatch) {
      console.log("textColor 원본:", textColorMatch[1]);
      const color = sanitizeColor(textColorMatch[1]);
      if (color) {
        cardData.textColor = color;
        console.log("textColor 복구:", cardData.textColor);
      } else {
        console.log("textColor 정리 실패");
      }
    } else {
      console.log("textColor 패턴 매칭 실패");
    }

    console.log("부분 복구 완료:", cardData);

    // 색상 정보가 없는 경우 템플릿별 기본 색상 적용
    if (!cardData.backgroundColor) {
      // 템플릿 이름과 이모지를 기반으로 기본 색상 추정
      const templateColors = getTemplateColors(cardData.name, cardData.emoji);
      cardData.backgroundColor = templateColors.backgroundColor;
      console.log("템플릿 기본 배경색 적용:", cardData.backgroundColor);
    }

    if (!cardData.textColor) {
      const templateColors = getTemplateColors(cardData.name, cardData.emoji);
      cardData.textColor = templateColors.textColor;
      console.log("템플릿 기본 텍스트 색상 적용:", cardData.textColor);
    }

    // 최소 필드 확인
    if (!cardData.name && !cardData.message) {
      throw new Error("복구 가능한 필수 필드가 없습니다.");
    }

    return cardData;
  } catch (error) {
    console.error("부분 복구 실패:", error);
    throw new Error(`부분 복구 실패: ${error.message}`);
  }
}

// 템플릿별 기본 색상 가져오기 함수 (실제 Flutter 템플릿 데이터 기반)
function getTemplateColors(templateName, emoji) {
  console.log("템플릿 색상 검색:", templateName, emoji);

  // Flutter에서 정의된 실제 템플릿 데이터
  const templates = {
    // 사랑 카테고리
    love_001: {
      backgroundColor: "#FFE4E6",
      textColor: "#E91E63",
      emoji: "💕",
      name: "사랑 고백",
    },
    love_002: {
      backgroundColor: "#FFF0F5",
      textColor: "#FF1744",
      emoji: "💖",
      name: "연인에게",
    },
    love_003: {
      backgroundColor: "#FFEBEE",
      textColor: "#AD1457",
      emoji: "🌹",
      name: "로맨틱",
    },

    // 축하 카테고리
    celebration_001: {
      backgroundColor: "#FFF3E0",
      textColor: "#FF9800",
      emoji: "🎉",
      name: "축하해요",
    },
    celebration_002: {
      backgroundColor: "#FFFDE7",
      textColor: "#F57F17",
      emoji: "🏆",
      name: "성취 축하",
    },
    celebration_003: {
      backgroundColor: "#F3E5F5",
      textColor: "#7B1FA2",
      emoji: "🎊",
      name: "기념일",
    },

    // 생일 카테고리
    birthday_001: {
      backgroundColor: "#E8F5E8",
      textColor: "#2E7D32",
      emoji: "🎂",
      name: "생일 축하",
    },
    birthday_002: {
      backgroundColor: "#E3F2FD",
      textColor: "#1565C0",
      emoji: "🎈",
      name: "생일 파티",
    },
    birthday_003: {
      backgroundColor: "#FCE4EC",
      textColor: "#C2185B",
      emoji: "🎁",
      name: "생일 선물",
    },

    // 위로 카테고리
    comfort_001: {
      backgroundColor: "#E0F2F1",
      textColor: "#00695C",
      emoji: "🤗",
      name: "위로",
    },
    comfort_002: {
      backgroundColor: "#E8EAF6",
      textColor: "#3F51B5",
      emoji: "💪",
      name: "응원",
    },
    comfort_003: {
      backgroundColor: "#FFF8E1",
      textColor: "#FF8F00",
      emoji: "☀️",
      name: "따뜻한 말",
    },

    // 우정 카테고리
    friendship_001: {
      backgroundColor: "#E1F5FE",
      textColor: "#0277BD",
      emoji: "👫",
      name: "친구에게",
    },
    friendship_002: {
      backgroundColor: "#E8F5E8",
      textColor: "#388E3C",
      emoji: "🤝",
      name: "우정",
    },
    friendship_003: {
      backgroundColor: "#F3E5F5",
      textColor: "#8E24AA",
      emoji: "📸",
      name: "추억",
    },

    // 감사 카테고리
    gratitude_001: {
      backgroundColor: "#EDE7F6",
      textColor: "#512DA8",
      emoji: "�",
      name: "감사 인사",
    },
    gratitude_002: {
      backgroundColor: "#FFF3E0",
      textColor: "#EF6C00",
      emoji: "💝",
      name: "고마워요",
    },
    gratitude_003: {
      backgroundColor: "#F9FBE7",
      textColor: "#689F38",
      emoji: "🌟",
      name: "감사 표현",
    },
  };

  // 1. 이모지 기반 정확한 매칭
  if (emoji) {
    for (const [templateId, template] of Object.entries(templates)) {
      if (template.emoji === emoji) {
        console.log(`이모지 정확 매칭: ${templateId}`, template);
        return {
          backgroundColor: template.backgroundColor,
          textColor: template.textColor,
        };
      }
    }
  }

  // 2. 템플릿 이름 기반 정확한 매칭
  if (templateName) {
    for (const [templateId, template] of Object.entries(templates)) {
      if (template.name === templateName) {
        console.log(`이름 정확 매칭: ${templateId}`, template);
        return {
          backgroundColor: template.backgroundColor,
          textColor: template.textColor,
        };
      }
    }
  }

  // 3. 이모지 기반 유사 매칭 (같은 카테고리 내에서)
  if (emoji) {
    // 사랑 관련 이모지들
    if (
      emoji.includes("💕") ||
      emoji.includes("💖") ||
      emoji.includes("🌹") ||
      emoji.includes("❤️") ||
      emoji.includes("💝") ||
      emoji.includes("💗")
    ) {
      console.log("사랑 카테고리 유사 매칭");
      return {
        backgroundColor: templates.love_001.backgroundColor,
        textColor: templates.love_001.textColor,
      };
    }
    // 축하 관련 이모지들
    else if (
      emoji.includes("🎉") ||
      emoji.includes("🏆") ||
      emoji.includes("🎊") ||
      emoji.includes("🎈") ||
      emoji.includes("🎆") ||
      emoji.includes("✨")
    ) {
      console.log("축하 카테고리 유사 매칭");
      return {
        backgroundColor: templates.celebration_001.backgroundColor,
        textColor: templates.celebration_001.textColor,
      };
    }
    // 생일 관련 이모지들
    else if (
      emoji.includes("🎂") ||
      emoji.includes("🎈") ||
      emoji.includes("�") ||
      emoji.includes("🍰") ||
      emoji.includes("🎀") ||
      emoji.includes("🎯")
    ) {
      console.log("생일 카테고리 유사 매칭");
      return {
        backgroundColor: templates.birthday_001.backgroundColor,
        textColor: templates.birthday_001.textColor,
      };
    }
    // 위로 관련 이모지들
    else if (
      emoji.includes("🤗") ||
      emoji.includes("💪") ||
      emoji.includes("☀️") ||
      emoji.includes("🫂") ||
      emoji.includes("🌸") ||
      emoji.includes("🌈")
    ) {
      console.log("위로 카테고리 유사 매칭");
      return {
        backgroundColor: templates.comfort_001.backgroundColor,
        textColor: templates.comfort_001.textColor,
      };
    }
    // 우정 관련 이모지들
    else if (
      emoji.includes("�") ||
      emoji.includes("�") ||
      emoji.includes("📸") ||
      emoji.includes("👭") ||
      emoji.includes("👬") ||
      emoji.includes("🤗")
    ) {
      console.log("우정 카테고리 유사 매칭");
      return {
        backgroundColor: templates.friendship_001.backgroundColor,
        textColor: templates.friendship_001.textColor,
      };
    }
    // 감사 관련 이모지들
    else if (
      emoji.includes("🙏") ||
      emoji.includes("💝") ||
      emoji.includes("🌟") ||
      emoji.includes("🤲") ||
      emoji.includes("✨") ||
      emoji.includes("💫")
    ) {
      console.log("감사 카테고리 유사 매칭");
      return {
        backgroundColor: templates.gratitude_001.backgroundColor,
        textColor: templates.gratitude_001.textColor,
      };
    }
  }

  // 4. 템플릿 이름 기반 키워드 매칭
  if (templateName) {
    const name = templateName.toLowerCase();

    if (
      name.includes("사랑") ||
      name.includes("연인") ||
      name.includes("로맨틱")
    ) {
      console.log("사랑 키워드 매칭");
      return {
        backgroundColor: templates.love_001.backgroundColor,
        textColor: templates.love_001.textColor,
      };
    } else if (
      name.includes("축하") ||
      name.includes("성취") ||
      name.includes("기념")
    ) {
      console.log("축하 키워드 매칭");
      return {
        backgroundColor: templates.celebration_001.backgroundColor,
        textColor: templates.celebration_001.textColor,
      };
    } else if (
      name.includes("생일") ||
      name.includes("파티") ||
      name.includes("선물")
    ) {
      console.log("생일 키워드 매칭");
      return {
        backgroundColor: templates.birthday_001.backgroundColor,
        textColor: templates.birthday_001.textColor,
      };
    } else if (
      name.includes("위로") ||
      name.includes("힐링") ||
      name.includes("응원") ||
      name.includes("따뜻")
    ) {
      console.log("위로 키워드 매칭");
      return {
        backgroundColor: templates.comfort_001.backgroundColor,
        textColor: templates.comfort_001.textColor,
      };
    } else if (
      name.includes("우정") ||
      name.includes("친구") ||
      name.includes("추억")
    ) {
      console.log("우정 키워드 매칭");
      return {
        backgroundColor: templates.friendship_001.backgroundColor,
        textColor: templates.friendship_001.textColor,
      };
    } else if (
      name.includes("감사") ||
      name.includes("고마") ||
      name.includes("표현")
    ) {
      console.log("감사 키워드 매칭");
      return {
        backgroundColor: templates.gratitude_001.backgroundColor,
        textColor: templates.gratitude_001.textColor,
      };
    }
  }

  // 5. 기본 색상 (매칭되지 않는 경우 - 첫 번째 템플릿 색상 사용)
  console.log("기본 템플릿 색상 사용");
  return {
    backgroundColor: templates.love_001.backgroundColor,
    textColor: templates.love_001.textColor,
  };
}

// JSON 문자열 정리 및 보정
function cleanJsonString(jsonString) {
  let cleaned = jsonString.trim();

  // 잘못된 색상 형식 수정
  cleaned = cleaned.replace(/"# \[([a-fA-F0-9]+)"/g, '"#$1"');
  cleaned = cleaned.replace(/([a-fA-F0-9]+)"\}/g, '$1"}');

  // 제어 문자 제거
  cleaned = cleaned.replace(/[\x00-\x1F\x7F]/g, "");

  return cleaned;
}

// 카드 데이터 유효성 검증
function validateCardData(cardData) {
  if (!cardData || typeof cardData !== "object") {
    throw new Error("카드 데이터가 올바른 객체가 아닙니다.");
  }

  if (!cardData.name && !cardData.message) {
    throw new Error("카드 데이터에 필수 필드(name 또는 message)가 없습니다.");
  }
}

// 카드 표시 함수
function displayCard(cardData) {
  hideLoadingAndShowCard();

  // 카드 데이터 설정
  setCardContent(cardData);

  // 스타일 적용
  applyCardStyles(cardData);

  // 애니메이션 시작
  startCardAnimation();
}

// 로딩 숨기고 카드 표시
function hideLoadingAndShowCard() {
  document.getElementById("loading").style.display = "none";

  const cardContainer = document.getElementById("cardContainer");
  const card = document.getElementById("card");

  cardContainer.style.display = "block";
  card.style.display = "block";
}

// 카드 콘텐츠 설정
function setCardContent(cardData) {
  if (cardData.emoji) {
    document.getElementById("emoji").textContent = cardData.emoji;
  }
  if (cardData.name) {
    document.getElementById("title").textContent = cardData.name;
  }
  if (cardData.message) {
    document.getElementById("message").textContent = cardData.message;
  }
}

// 카드 스타일 적용
function applyCardStyles(cardData) {
  const card = document.getElementById("card");

  // 배경색 적용
  if (cardData.backgroundColor) {
    const bgColor = sanitizeColor(cardData.backgroundColor);
    if (bgColor) {
      card.style.backgroundColor = bgColor;
    }
  }

  // 텍스트 색상 적용
  if (cardData.textColor) {
    const textColor = sanitizeColor(cardData.textColor);
    if (textColor) {
      card.style.color = textColor;
    }
  }
}

// 색상 값 정리 및 검증 (강화된 처리)
function sanitizeColor(colorValue) {
  if (!colorValue || typeof colorValue !== "string") {
    console.log("색상 값이 비어있거나 문자열이 아님:", colorValue);
    return null;
  }

  let color = colorValue.trim();
  console.log("색상 정리 전:", JSON.stringify(color));

  // 다양한 잘못된 형식 수정
  // "# [f3e5f5" → "#f3e5f5"
  if (color.includes("# [")) {
    console.log("패턴 1 감지: '# [' 형식");
    color = color.replace(/# \[([a-fA-F0-9]+).*/, "#$1");
    console.log("패턴 1 변환 후:", color);
  }

  // "[f3e5f5" → "#f3e5f5"
  if (color.includes("[") && !color.startsWith("#")) {
    console.log("패턴 2 감지: '[' 형식");
    color = color.replace(/\[([a-fA-F0-9]+).*/, "#$1");
    console.log("패턴 2 변환 후:", color);
  }

  // "f3e5f5" → "#f3e5f5" (# 누락된 경우)
  if (
    /^[a-fA-F0-9]+$/.test(color) &&
    (color.length === 3 || color.length === 6)
  ) {
    console.log("패턴 3 감지: # 누락");
    color = "#" + color;
    console.log("패턴 3 변환 후:", color);
  }

  // 끝부분 특수문자 제거
  const beforeClean = color;
  color = color.replace(/[^a-fA-F0-9#].*$/, "");
  if (beforeClean !== color) {
    console.log("특수문자 제거:", beforeClean, "→", color);
  }

  console.log("색상 정리 완료:", JSON.stringify(color));

  // 유효한 색상 형식인지 확인
  if (color.startsWith("#") && (color.length === 4 || color.length === 7)) {
    const hexPart = color.substring(1);
    if (/^[a-fA-F0-9]+$/.test(hexPart)) {
      console.log("✅ 유효한 색상:", color);
      return color;
    }
  }

  console.warn("❌ 유효하지 않은 색상 형식:", colorValue, "→", color);
  return null;
}

// 카드 애니메이션 시작
function startCardAnimation() {
  const cardContainer = document.getElementById("cardContainer");
  const card = document.getElementById("card");

  setTimeout(() => {
    cardContainer.classList.add("show");
    setTimeout(() => {
      card.classList.add("show");
    }, 300);
  }, 100);
}

// 기본 카드 표시 함수
function displayDefaultCard(shareId) {
  hideLoadingAndShowCard();

  // 기본 메시지 설정
  setDefaultCardContent(shareId);

  // 애니메이션 시작
  startCardAnimation();
}

// 기본 카드 콘텐츠 설정
function setDefaultCardContent(shareId) {
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
