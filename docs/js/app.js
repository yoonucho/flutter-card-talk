// 인트로 애니메이션 설정
document.addEventListener("DOMContentLoaded", function () {
  // URL에서 공유 ID 가져오기
  const urlParams = new URLSearchParams(window.location.search);
  const shareId = urlParams.get("id");

  // 인트로 애니메이션 (view.html에서만 실행)
  if (document.getElementById("introText")) {
    setTimeout(() => {
      document.getElementById("introText").classList.add("show");
    }, 500);

    setTimeout(() => {
      document.getElementById("introSubtext").classList.add("show");
    }, 800);

    setTimeout(() => {
      document.getElementById("introButton").classList.add("show");
    }, 1200);

    // 인트로 버튼 클릭 이벤트
    document
      .getElementById("introButton")
      .addEventListener("click", function () {
        // 인트로 화면 숨기기
        document.getElementById("intro").style.opacity = "0";

        // 카드 화면 표시
        document.getElementById("cardContainer").style.opacity = "1";

        // 인트로 화면 완전히 제거
        setTimeout(() => {
          document.getElementById("intro").style.display = "none";

          // 카드 데이터 가져오기
          if (shareId) {
            loadCardData(shareId);
          } else {
            showError("카드 ID가 없습니다.");
          }
        }, 1000);

        // 하트 효과 생성
        createHearts();
      });
  }

  // 공유 페이지 링크 설정 (share.html에서만 실행)
  if (window.location.pathname.includes("share.html")) {
    if (shareId) {
      // 앱 링크 설정
      const appLink = document.getElementById("appLink");
      if (appLink) {
        appLink.href = `cardtalk://share/${shareId}`;
      }

      // 웹 링크 설정
      const webLink = document.getElementById("webLink");
      if (webLink) {
        webLink.href = `view.html?id=${shareId}&data=${urlParams.get("data")}`;
      }
    } else {
      // ID가 없는 경우
      const titleEl = document.querySelector(".title");
      const messageEl = document.querySelector(".message");
      const appLinkEl = document.getElementById("appLink");
      const webLinkEl = document.getElementById("webLink");

      if (titleEl) titleEl.textContent = "잘못된 접근입니다";
      if (messageEl) messageEl.textContent = "유효한 공유 링크가 아닙니다";
      if (appLinkEl) appLinkEl.style.display = "none";
      if (webLinkEl) webLinkEl.style.display = "none";
    }
  }
});

// 카드 데이터 가져오기 함수
function loadCardData(shareId) {
  try {
    // URL 파라미터에서 카드 데이터 가져오기
    const urlParams = new URLSearchParams(window.location.search);
    const encodedData = urlParams.get("data");

    if (encodedData) {
      try {
        // Base64 디코딩 및 JSON 파싱
        const jsonData = atob(encodedData);
        const cardData = JSON.parse(jsonData);

        // 카드 데이터 표시
        displayCard(cardData);
      } catch (decodeError) {
        console.error("데이터 디코딩 오류:", decodeError);
        displayDefaultCard(shareId);
      }
    } else {
      // 데이터가 없는 경우 기본 카드 표시
      displayDefaultCard(shareId);
    }
  } catch (error) {
    console.error("Error:", error);
    showError("카드 정보를 불러오는데 실패했습니다: " + error.message);
  }
}

// 기본 카드 표시 (데이터가 없는 경우)
function displayDefaultCard(shareId) {
  document.getElementById("emoji").textContent = "💌";
  document.getElementById("title").textContent = "특별한 카드";
  document.getElementById("message").textContent =
    "카드톡에서 보낸 특별한 카드입니다.\n카드를 확인하려면 카드톡 앱을 설치하거나 공유 링크를 통해 확인해주세요.";

  // 카드 스타일 설정
  const card = document.getElementById("card");
  card.style.backgroundColor = "#ffffff";

  // 텍스트 색상 설정
  document.getElementById("title").style.color = "#e91e63";
  document.getElementById("message").style.color = "#333333";

  // 로딩 숨기고 카드 표시
  document.getElementById("loading").style.display = "none";
  document.getElementById("card").style.display = "block";

  // 애니메이션 효과
  setTimeout(() => {
    document.getElementById("card").classList.add("show");
    document.getElementById("cardContainer").classList.add("show");
    createConfetti();
  }, 100);
}

// 카드 데이터 표시
function displayCard(data) {
  document.getElementById("emoji").textContent = data.emoji || "💌";
  document.getElementById("title").textContent = data.name || "카드 제목";
  document.getElementById("message").textContent =
    data.message || "카드 메시지";

  // 카드 스타일 설정
  const card = document.getElementById("card");
  card.style.backgroundColor = data.backgroundColor || "#ffffff";

  // 텍스트 색상 설정
  document.getElementById("title").style.color = data.textColor || "#e91e63";
  document.getElementById("message").style.color = data.textColor || "#333333";

  // 로딩 숨기고 카드 표시
  document.getElementById("loading").style.display = "none";
  document.getElementById("card").style.display = "block";

  // 애니메이션 효과
  setTimeout(() => {
    document.getElementById("card").classList.add("show");
    document.getElementById("cardContainer").classList.add("show");
    createConfetti();
  }, 100);
}

// 오류 표시 함수
function showError(message) {
  document.getElementById("loading").style.display = "none";
  const errorElement = document.getElementById("error");
  const errorMessageElement = document.getElementById("errorMessage");
  if (errorMessageElement) {
    errorMessageElement.textContent = message;
  }
  errorElement.style.display = "block";
}

// 하트 효과 생성 함수
function createHearts() {
  const container = document.querySelector(".container");

  for (let i = 0; i < 20; i++) {
    const heart = document.createElement("div");
    heart.className = "heart";

    // 랜덤 위치
    heart.style.left = Math.random() * 100 + "%";
    heart.style.top = Math.random() * 100 + "%";

    // 랜덤 크기
    const size = Math.random() * 15 + 10;
    heart.style.width = size + "px";
    heart.style.height = size + "px";

    // 랜덤 색상
    const colors = ["#ff9aac", "#ff6b8b", "#ff3e6d", "#ff1e4d"];
    const color = colors[Math.floor(Math.random() * colors.length)];
    heart.style.backgroundColor = color;

    container.appendChild(heart);

    // 애니메이션
    heart.animate(
      [
        {
          opacity: 0,
          transform: "rotate(45deg) translate(0, 0) scale(0)",
        },
        {
          opacity: 0.8,
          transform: "rotate(45deg) translate(0, -100px) scale(1)",
        },
        {
          opacity: 0,
          transform: "rotate(45deg) translate(0, -200px) scale(0.5)",
        },
      ],
      {
        duration: Math.random() * 2000 + 1000,
        delay: Math.random() * 500,
        easing: "ease-out",
        iterations: 1,
      }
    );

    // 애니메이션 후 요소 제거
    setTimeout(() => {
      heart.remove();
    }, 3000);
  }
}

// 색종이 효과 생성 함수
function createConfetti() {
  const card = document.getElementById("card");
  const colors = ["#ff9aac", "#a8e6cf", "#ffd3b6", "#d4a5ff", "#ffccd5"];

  for (let i = 0; i < 50; i++) {
    const confetti = document.createElement("div");
    confetti.className = "confetti";
    confetti.style.backgroundColor =
      colors[Math.floor(Math.random() * colors.length)];
    confetti.style.left = Math.random() * 100 + "%";
    confetti.style.top = -20 + "px";
    confetti.style.width = Math.random() * 8 + 5 + "px";
    confetti.style.height = Math.random() * 8 + 5 + "px";
    confetti.style.opacity = Math.random();
    confetti.style.transform = "rotate(" + Math.random() * 360 + "deg)";

    card.appendChild(confetti);

    // 애니메이션
    const delay = Math.random() * 3;
    const duration = Math.random() * 3 + 2;

    confetti.animate(
      [
        { transform: "translate(0, 0) rotate(0deg)", opacity: 1 },
        {
          transform:
            "translate(" +
            (Math.random() * 200 - 100) +
            "px, " +
            (Math.random() * 200 + 100) +
            "px) rotate(" +
            Math.random() * 360 +
            "deg)",
          opacity: 0,
        },
      ],
      {
        duration: duration * 1000,
        delay: delay * 1000,
        fill: "forwards",
      }
    );

    // 애니메이션 후 요소 제거
    setTimeout(() => {
      confetti.remove();
    }, (delay + duration) * 1000);
  }
}
