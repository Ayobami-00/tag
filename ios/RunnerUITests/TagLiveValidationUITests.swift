import XCTest

final class TagLiveValidationUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  func testAllowNotificationPromptIfVisible() throws {
    let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    let alert = springboard.alerts.firstMatch
    XCTAssertTrue(alert.waitForExistence(timeout: 10))

    if alert.buttons["Allow"].exists {
      alert.buttons["Allow"].tap()
    } else if alert.buttons.firstMatch.exists {
      alert.buttons.firstMatch.tap()
    }
  }

  func testCanLaunchAndReachOnboarding() throws {
    let app = XCUIApplication(bundleIdentifier: "com.usetag.tag")
    app.launch()

    XCTAssertTrue(app.wait(for: .runningForeground, timeout: 20))
    sleep(2)

    attachScreenshot(named: "tag-launch-state")
    tap(app: app, x: 0.50, y: 0.55)
    sleep(1)
    attachScreenshot(named: "tag-nickname")
    tap(app: app, x: 0.50, y: 0.37)
    app.typeText("Alex\n")
    sleep(2)
    attachScreenshot(named: "tag-avatar")
    tap(app: app, x: 0.50, y: 0.68)
    sleep(1)
    attachScreenshot(named: "tag-local-first")
    tap(app: app, x: 0.50, y: 0.70)
    sleep(1)
    attachScreenshot(named: "tag-notifications")
    tap(app: app, x: 0.50, y: 0.58)
    sleep(1)
    attachScreenshot(named: "tag-share")
    tap(app: app, x: 0.50, y: 0.70)
    sleep(3)
    attachScreenshot(named: "tag-today")
  }

  func testPhotosLibraryProbe() throws {
    let photos = XCUIApplication(bundleIdentifier: "com.apple.mobileslideshow")
    photos.launch()
    XCTAssertTrue(photos.wait(for: .runningForeground, timeout: 20))
    sleep(3)
    attachScreenshot(named: "photos-launch")
    tap(app: photos, x: 0.50, y: 0.91)
    sleep(3)
    attachScreenshot(named: "photos-after-continue")
    tap(app: photos, x: 0.32, y: 0.60)
    sleep(2)
    attachScreenshot(named: "photos-library-ready")
    tap(app: photos, x: 0.50, y: 0.54)
    sleep(2)
    attachScreenshot(named: "photos-recently-saved")
  }

  func testPhotosOpenFirstItemProbe() throws {
    let photos = XCUIApplication(bundleIdentifier: "com.apple.mobileslideshow")
    photos.launch()
    XCTAssertTrue(photos.wait(for: .runningForeground, timeout: 20))
    sleep(2)
    attachScreenshot(named: "photos-before-open-first")
    tap(app: photos, x: 0.50, y: 0.51)
    sleep(2)
    attachScreenshot(named: "photos-open-recently-saved")
    tap(app: photos, x: 0.17, y: 0.29)
    sleep(2)
    attachScreenshot(named: "photos-first-open")
  }

  func testPhotosShareFirstItemProbe() throws {
    let photos = XCUIApplication(bundleIdentifier: "com.apple.mobileslideshow")
    photos.launch()
    XCTAssertTrue(photos.wait(for: .runningForeground, timeout: 20))
    sleep(2)
    tap(app: photos, x: 0.50, y: 0.51)
    sleep(1)
    tap(app: photos, x: 0.17, y: 0.29)
    sleep(1)
    attachScreenshot(named: "photos-first-before-share")
    tap(app: photos, x: 0.13, y: 0.93)
    sleep(3)
    attachScreenshot(named: "photos-first-share-sheet")
    tap(app: photos, x: 0.39, y: 0.63)
    sleep(2)
    attachScreenshot(named: "tag-share-extension-result")

    let tag = XCUIApplication(bundleIdentifier: "com.usetag.tag")
    tag.launch()
    XCTAssertTrue(tag.wait(for: .runningForeground, timeout: 20))
    sleep(45)
    attachScreenshot(named: "tag-after-first-share-import-45s")
    sleep(45)
    attachScreenshot(named: "tag-after-first-share-import-90s")
  }

  func testShareNewestPhotoToTagFastProbe() throws {
    let photos = XCUIApplication(bundleIdentifier: "com.apple.mobileslideshow")
    photos.launch()
    XCTAssertTrue(photos.wait(for: .runningForeground, timeout: 20))
    openRecentlySavedGrid(in: photos)

    tap(app: photos, x: 0.17, y: 0.29)
    sleep(1)
    attachScreenshot(named: "fast-share-newest-before-share")
    shareCurrentPhotoToTag(in: photos)
    attachScreenshot(named: "fast-share-newest-result")

    let tag = XCUIApplication(bundleIdentifier: "com.usetag.tag")
    tag.launch()
    XCTAssertTrue(tag.wait(for: .runningForeground, timeout: 20))
    sleep(6)
    attachScreenshot(named: "fast-share-tag-after-6s")
  }

  func testPreOnboardingShareThenFinishOnboardingProbe() throws {
    let photos = XCUIApplication(bundleIdentifier: "com.apple.mobileslideshow")
    photos.launch()
    XCTAssertTrue(photos.wait(for: .runningForeground, timeout: 20))
    dismissPhotosFirstRunIfPresent(in: photos)
    openRecentlySavedGrid(in: photos)
    tap(app: photos, x: 0.17, y: 0.29)
    sleep(2)
    attachScreenshot(named: "preonboarding-photo-before-share")
    shareCurrentPhotoToTag(in: photos)
    attachScreenshot(named: "preonboarding-share-extension-result")

    let tag = XCUIApplication(bundleIdentifier: "com.usetag.tag")
    tag.launch()
    XCTAssertTrue(tag.wait(for: .runningForeground, timeout: 20))
    sleep(3)
    attachScreenshot(named: "preonboarding-tag-launch")

    tap(app: tag, x: 0.50, y: 0.55)
    sleep(1)
    attachScreenshot(named: "preonboarding-nickname")
    tap(app: tag, x: 0.50, y: 0.37)
    tag.typeText("Pre Share\n")
    sleep(2)
    attachScreenshot(named: "preonboarding-avatar")
    tap(app: tag, x: 0.50, y: 0.68)
    sleep(1)
    attachScreenshot(named: "preonboarding-local-first")
    tap(app: tag, x: 0.50, y: 0.70)
    sleep(1)
    attachScreenshot(named: "preonboarding-notifications")
    tap(app: tag, x: 0.50, y: 0.58)
    sleep(1)
    attachScreenshot(named: "preonboarding-share-step")
    tap(app: tag, x: 0.50, y: 0.70)
    sleep(10)
    attachScreenshot(named: "preonboarding-today-after-10s")
    sleep(50)
    attachScreenshot(named: "preonboarding-today-after-60s")
    sleep(120)
    attachScreenshot(named: "preonboarding-today-after-180s")
  }

  func testPreOnboardingShareThenFinishOnboardingFastProbe() throws {
    let tagWarmup = XCUIApplication(bundleIdentifier: "com.usetag.tag")
    tagWarmup.launch()
    XCTAssertTrue(tagWarmup.wait(for: .runningForeground, timeout: 20))
    sleep(2)
    attachScreenshot(named: "preonboarding-fast-tag-first-launch")
    tagWarmup.terminate()
    sleep(2)

    let photos = XCUIApplication(bundleIdentifier: "com.apple.mobileslideshow")
    photos.launch()
    XCTAssertTrue(photos.wait(for: .runningForeground, timeout: 20))
    dismissPhotosFirstRunIfPresent(in: photos)
    openRecentlySavedGrid(in: photos)
    tap(app: photos, x: 0.17, y: 0.29)
    sleep(2)
    attachScreenshot(named: "preonboarding-fast-photo-before-share")
    shareCurrentPhotoToTag(in: photos)
    attachScreenshot(named: "preonboarding-fast-share-extension-result")

    let tag = XCUIApplication(bundleIdentifier: "com.usetag.tag")
    tag.launch()
    XCTAssertTrue(tag.wait(for: .runningForeground, timeout: 20))
    sleep(3)
    attachScreenshot(named: "preonboarding-fast-tag-launch")

    completeOnboarding(
      in: tag,
      nickname: "Pre Share",
      modelChoice: "Fastest",
      screenshotPrefix: "preonboarding-fast"
    )

    sleep(20)
    attachScreenshot(named: "preonboarding-fast-today-after-20s")
  }

  func testBestQualityOnboardingProbe() throws {
    let tag = XCUIApplication(bundleIdentifier: "com.usetag.tag")
    tag.launch()
    XCTAssertTrue(tag.wait(for: .runningForeground, timeout: 20))
    sleep(3)
    attachScreenshot(named: "best-quality-launch")

    completeOnboarding(
      in: tag,
      nickname: "Quality Pass",
      modelChoice: "Best quality",
      screenshotPrefix: "best-quality"
    )

    sleep(8)
    attachScreenshot(named: "best-quality-today-after-8s")
    sleep(60)
    attachScreenshot(named: "best-quality-today-after-68s")
  }

  func testPhotosBatchShareVisibleFixtureGrid() throws {
    let photos = XCUIApplication(bundleIdentifier: "com.apple.mobileslideshow")
    photos.launch()
    XCTAssertTrue(photos.wait(for: .runningForeground, timeout: 20))
    sleep(2)

    if !photos.buttons["Select"].waitForExistence(timeout: 2) {
      tap(app: photos, x: 0.10, y: 0.09)
      sleep(2)
    }

    if !photos.buttons["Select"].waitForExistence(timeout: 2) {
      tap(app: photos, x: 0.50, y: 0.51)
      sleep(2)
    }

    attachScreenshot(named: "photos-batch-grid-before-select")
    if photos.buttons["Select"].waitForExistence(timeout: 5) {
      photos.buttons["Select"].tap()
    } else {
      tap(app: photos, x: 0.86, y: 0.09)
    }
    sleep(1)
    attachScreenshot(named: "photos-batch-select-mode")

    let fixtureCoordinates: [(CGFloat, CGFloat)] = [
      (0.50, 0.29),
      (0.83, 0.29),
      (0.17, 0.45),
      (0.50, 0.45),
      (0.83, 0.45),
      (0.17, 0.62),
      (0.50, 0.62),
      (0.83, 0.62),
    ]
    for coordinate in fixtureCoordinates {
      tap(app: photos, x: coordinate.0, y: coordinate.1)
      usleep(250_000)
    }

    attachScreenshot(named: "photos-batch-selected-fixtures")
    tap(app: photos, x: 0.13, y: 0.93)
    sleep(3)
    attachScreenshot(named: "photos-batch-share-sheet")

    if photos.buttons["Tag"].waitForExistence(timeout: 3) {
      photos.buttons["Tag"].tap()
    } else {
      tap(app: photos, x: 0.39, y: 0.63)
    }
    sleep(4)
    attachScreenshot(named: "photos-batch-share-result")

    let tag = XCUIApplication(bundleIdentifier: "com.usetag.tag")
    tag.launch()
    XCTAssertTrue(tag.wait(for: .runningForeground, timeout: 20))
    sleep(120)
    attachScreenshot(named: "tag-after-batch-share-120s")
    sleep(180)
    attachScreenshot(named: "tag-after-batch-share-300s")
  }

  func testPhotosShareTopRightFixtureProbe() throws {
    let photos = XCUIApplication(bundleIdentifier: "com.apple.mobileslideshow")
    photos.launch()
    XCTAssertTrue(photos.wait(for: .runningForeground, timeout: 20))
    openRecentlySavedGrid(in: photos)

    tap(app: photos, x: 0.83, y: 0.29)
    sleep(2)
    attachScreenshot(named: "photos-top-right-before-share")
    shareCurrentPhotoToTag(in: photos)
    attachScreenshot(named: "photos-top-right-share-result")

    let tag = XCUIApplication(bundleIdentifier: "com.usetag.tag")
    tag.launch()
    XCTAssertTrue(tag.wait(for: .runningForeground, timeout: 20))
    sleep(60)
    attachScreenshot(named: "tag-after-top-right-share-60s")
    sleep(60)
    attachScreenshot(named: "tag-after-top-right-share-120s")
  }

  func testPhotosShareVisibleFixturesIndividually() throws {
    let photos = XCUIApplication(bundleIdentifier: "com.apple.mobileslideshow")
    photos.launch()
    XCTAssertTrue(photos.wait(for: .runningForeground, timeout: 20))
    openRecentlySavedGrid(in: photos)

    let fixtureCoordinates: [(String, CGFloat, CGFloat)] = [
      ("llm-job-post", 0.50, 0.29),
      ("sister-call", 0.83, 0.29),
      ("ai-saturdays", 0.17, 0.45),
      ("attention-qkv", 0.50, 0.45),
      ("uk-company", 0.83, 0.45),
      ("medium-article", 0.17, 0.62),
      ("linkedin-application", 0.50, 0.62),
      ("llm-internals", 0.83, 0.62),
    ]

    for fixture in fixtureCoordinates {
      tap(app: photos, x: fixture.1, y: fixture.2)
      sleep(2)
      attachScreenshot(named: "photos-individual-\(fixture.0)-before-share")
      shareCurrentPhotoToTag(in: photos)
      attachScreenshot(named: "photos-individual-\(fixture.0)-share-result")
      tap(app: photos, x: 0.10, y: 0.09)
      sleep(2)
      openRecentlySavedGrid(in: photos)
    }

    let tag = XCUIApplication(bundleIdentifier: "com.usetag.tag")
    tag.launch()
    XCTAssertTrue(tag.wait(for: .runningForeground, timeout: 20))
    sleep(180)
    attachScreenshot(named: "tag-after-individual-fixtures-180s")
    sleep(240)
    attachScreenshot(named: "tag-after-individual-fixtures-420s")
  }

  func testChatAskSavedContextProbe() throws {
    let tag = XCUIApplication(bundleIdentifier: "com.usetag.tag")
    tag.launch()
    XCTAssertTrue(tag.wait(for: .runningForeground, timeout: 20))
    sleep(5)
    attachScreenshot(named: "chat-probe-today-before-fab")

    tap(app: tag, x: 0.87, y: 0.91)
    sleep(2)
    attachScreenshot(named: "chat-probe-fab-open")

    if tag.buttons["Ask Tag"].waitForExistence(timeout: 3) {
      tag.buttons["Ask Tag"].tap()
    } else if tag.staticTexts["Ask Tag"].waitForExistence(timeout: 3) {
      tag.staticTexts["Ask Tag"].tap()
    } else {
      tap(app: tag, x: 0.72, y: 0.81)
    }

    sleep(3)
    attachScreenshot(named: "chat-probe-chat-open")

    let prompt = "Do I have anything about cooking recipes?"
    if tag.textViews.firstMatch.waitForExistence(timeout: 5) {
      tag.textViews.firstMatch.tap()
      tag.typeText(prompt)
    } else if tag.textFields.firstMatch.waitForExistence(timeout: 5) {
      tag.textFields.firstMatch.tap()
      tag.typeText(prompt)
    } else {
      tap(app: tag, x: 0.42, y: 0.92)
      tag.typeText(prompt)
    }

    sleep(1)
    attachScreenshot(named: "chat-probe-question-entered")

    tap(app: tag, x: 0.89, y: 0.92)

    sleep(2)
    attachScreenshot(named: "chat-probe-loading")
    sleep(25)
    attachScreenshot(named: "chat-probe-answer")
  }

  func testRequiredChatMatrixProbe() throws {
    let tag = XCUIApplication(bundleIdentifier: "com.usetag.tag")
    tag.launch()
    XCTAssertTrue(tag.wait(for: .runningForeground, timeout: 20))
    sleep(5)
    attachScreenshot(named: "chat-matrix-today-before-fab")

    openAskTag(in: tag)
    attachScreenshot(named: "chat-matrix-chat-open")

    let questions: [(String, String)] = [
      ("uk-company", "What UK company formation information have I saved?"),
      ("llm-internals", "What LLM internals resources have I saved?"),
      ("job-applications", "What job applications do I need to follow up on?"),
      ("personal-weekend", "What personal reminders do I have this weekend?"),
      ("ai-saturdays-why", "Why did you create the AI Saturdays card?"),
      ("sister-source", "Show me the source for my sister call reminder."),
      ("attention", "What have I saved about attention?"),
      ("learning-next", "What should I do next for my saved learning resources?"),
      ("cooking-none", "Do I have anything about cooking recipes?"),
      ("uk-reminder", "Create a reminder from my UK company source."),
    ]

    for question in questions {
      ask(question.1, label: question.0, in: tag)
    }
  }

  func testFocusedChatQualityProbe() throws {
    let tag = XCUIApplication(bundleIdentifier: "com.usetag.tag")
    tag.launch()
    XCTAssertTrue(tag.wait(for: .runningForeground, timeout: 20))
    sleep(5)
    attachScreenshot(named: "chat-focused-today-before-fab")

    openAskTag(in: tag)
    attachScreenshot(named: "chat-focused-chat-open")

    let questions: [(String, String)] = [
      ("job-applications", "What job applications do I need to follow up on?"),
      ("sister-source", "Show me the source for my sister call reminder."),
      ("ai-saturdays-why", "Why did you create the AI Saturdays card?"),
      ("uk-reminder", "Create a reminder from my UK company source."),
    ]

    for question in questions {
      ask(question.1, label: "focused-\(question.0)", in: tag)
    }
  }

  func testFocusedJobApplicationChatProbe() throws {
    let tag = XCUIApplication(bundleIdentifier: "com.usetag.tag")
    tag.launch()
    XCTAssertTrue(tag.wait(for: .runningForeground, timeout: 20))
    sleep(5)
    attachScreenshot(named: "chat-job-focused-today-before-fab")

    openAskTag(in: tag)
    attachScreenshot(named: "chat-job-focused-chat-open")
    ask(
      "What job applications do I need to follow up on?",
      label: "job-focused-application",
      in: tag
    )
  }

  func testFastChatLatencyProbe() throws {
    let tag = XCUIApplication(bundleIdentifier: "com.usetag.tag")
    tag.launch()
    XCTAssertTrue(tag.wait(for: .runningForeground, timeout: 20))
    sleep(2)
    attachScreenshot(named: "chat-fast-today-before-fab")

    openAskTag(in: tag)
    attachScreenshot(named: "chat-fast-chat-open")

    let questions: [(String, String)] = [
      ("uk-company", "What UK company formation information have I saved?"),
      ("job-applications", "What job applications do I need to follow up on?"),
      ("sister-source", "Show me the source for my sister call reminder."),
      ("cooking-none", "Do I have anything about cooking recipes?"),
    ]

    for question in questions {
      askFast(question.1, label: "fast-\(question.0)", in: tag)
    }
  }

  private func openRecentlySavedGrid(in photos: XCUIApplication) {
    sleep(1)
    dismissPhotosFirstRunIfPresent(in: photos)
    if photos.staticTexts["Apps"].exists {
      tap(app: photos, x: 0.10, y: 0.12)
      sleep(1)
    }
    if photos.buttons["Cancel"].exists {
      photos.buttons["Cancel"].tap()
      sleep(1)
    }
    if !photos.staticTexts["Recently Saved"].waitForExistence(timeout: 1) {
      tap(app: photos, x: 0.10, y: 0.09)
      sleep(1)
    }
    if photos.staticTexts["Library"].exists {
      tap(app: photos, x: 0.41, y: 0.95)
      sleep(1)
    }
    if photos.staticTexts["Collections"].waitForExistence(timeout: 2) {
      tap(app: photos, x: 0.50, y: 0.48)
      sleep(2)
    }
    attachScreenshot(named: "photos-recently-saved-grid-ready")
  }

  private func dismissPhotosFirstRunIfPresent(in photos: XCUIApplication) {
    if photos.buttons["Continue"].waitForExistence(timeout: 3) {
      photos.buttons["Continue"].tap()
      sleep(2)
    }

    if photos.buttons["Not Now"].waitForExistence(timeout: 1) {
      photos.buttons["Not Now"].tap()
      sleep(1)
    } else if photos.buttons["Don’t Allow"].waitForExistence(timeout: 1) {
      photos.buttons["Don’t Allow"].tap()
      sleep(1)
    }
  }

  private func shareCurrentPhotoToTag(in photos: XCUIApplication) {
    _ = dismissSystemAlertIfPresent()
    openFirstVisiblePhotoIfNeeded(in: photos)
    tapShareControl(in: photos)
    sleep(1)
    if dismissSystemAlertIfPresent() {
      sleep(1)
      tapShareControl(in: photos)
    }
    sleep(3)
    attachScreenshot(named: "photos-single-share-sheet")
    let tagButton = photos.buttons["Tag"].firstMatch
    let tagLabel = photos.staticTexts["Tag"].firstMatch
    if tagButton.waitForExistence(timeout: 3) {
      tagButton.tap()
    } else if tagLabel.waitForExistence(timeout: 2) {
      tagLabel.tap()
    } else {
      openShareSheetMoreAppsAndChooseTag(in: photos)
    }
    sleep(3)
  }

  private func openShareSheetMoreAppsAndChooseTag(in photos: XCUIApplication) {
    if photos.buttons["More"].waitForExistence(timeout: 2) {
      photos.buttons["More"].tap()
    } else {
      tap(app: photos, x: 0.62, y: 0.64)
    }
    sleep(2)
    attachScreenshot(named: "photos-share-more-sheet")
    chooseTagFromMoreApps(in: photos)
  }

  private func chooseTagFromMoreApps(in photos: XCUIApplication) {
    for attempt in 0..<5 {
      let tagButton = photos.buttons["Tag"].firstMatch
      let tagLabel = photos.staticTexts["Tag"].firstMatch
      if tagButton.waitForExistence(timeout: 1) {
        tagButton.tap()
        return
      }
      if tagLabel.waitForExistence(timeout: 1) {
        tagLabel.tap()
        return
      }

      if attempt < 4 {
        photos.swipeUp()
        sleep(1)
        attachScreenshot(named: "photos-share-more-sheet-scroll-\(attempt + 1)")
      }
    }

    tap(app: photos, x: 0.50, y: 0.39)
  }

  private func openFirstVisiblePhotoIfNeeded(in photos: XCUIApplication) {
    let looksLikeGrid = photos.buttons["Select"].exists || photos.staticTexts["Library"].exists
    guard looksLikeGrid else {
      return
    }

    tap(app: photos, x: 0.17, y: 0.29)
    sleep(2)
  }

  private func tapShareControl(in photos: XCUIApplication) {
    if photos.buttons["Share"].waitForExistence(timeout: 1) {
      photos.buttons["Share"].tap()
      return
    }

    tap(app: photos, x: 0.13, y: 0.89)
  }

  @discardableResult
  private func dismissSystemAlertIfPresent() -> Bool {
    let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    let alert = springboard.alerts.firstMatch
    guard alert.waitForExistence(timeout: 2) else {
      return false
    }

    if alert.buttons["Allow"].exists {
      alert.buttons["Allow"].tap()
    } else if alert.buttons["Don’t Allow"].exists {
      alert.buttons["Don’t Allow"].tap()
    } else if alert.buttons.firstMatch.exists {
      alert.buttons.firstMatch.tap()
    }

    sleep(1)
    return true
  }

  private func openAskTag(in tag: XCUIApplication) {
    tap(app: tag, x: 0.87, y: 0.91)
    sleep(2)
    if tag.buttons["Ask Tag"].waitForExistence(timeout: 3) {
      tag.buttons["Ask Tag"].tap()
    } else if tag.staticTexts["Ask Tag"].waitForExistence(timeout: 3) {
      tag.staticTexts["Ask Tag"].tap()
    } else {
      tap(app: tag, x: 0.72, y: 0.81)
    }
    sleep(3)
  }

  private func completeOnboarding(
    in tag: XCUIApplication,
    nickname: String,
    modelChoice: String,
    screenshotPrefix: String
  ) {
    tapButtonOrCoordinate(
      in: tag,
      labels: ["Start", "onboarding_start_button"],
      fallbackX: 0.50,
      fallbackY: 0.55
    )
    sleep(1)
    attachScreenshot(named: "\(screenshotPrefix)-nickname")

    if tag.textFields.firstMatch.waitForExistence(timeout: 5) {
      tag.textFields.firstMatch.tap()
    } else {
      tap(app: tag, x: 0.50, y: 0.37)
    }
    tag.typeText("\(nickname)\n")
    sleep(2)
    attachScreenshot(named: "\(screenshotPrefix)-avatar")

    tapButtonOrCoordinate(
      in: tag,
      labels: ["Use selected"],
      fallbackX: 0.50,
      fallbackY: 0.68
    )
    sleep(1)
    attachScreenshot(named: "\(screenshotPrefix)-local-first")

    let modelFallbackY: CGFloat = modelChoice == "Best quality" ? 0.78 : 0.70
    tapButtonOrCoordinate(
      in: tag,
      labels: [modelChoice],
      fallbackX: 0.50,
      fallbackY: modelFallbackY
    )
    sleep(1)
    attachScreenshot(named: "\(screenshotPrefix)-notifications")

    tapButtonOrCoordinate(
      in: tag,
      labels: ["Skip for now", "Enable notifications"],
      fallbackX: 0.50,
      fallbackY: 0.58
    )
    sleep(1)
    attachScreenshot(named: "\(screenshotPrefix)-share")

    tapButtonOrCoordinate(
      in: tag,
      labels: ["Go to Today", "finish_onboarding_button"],
      fallbackX: 0.50,
      fallbackY: 0.70
    )
  }

  private func tapButtonOrCoordinate(
    in app: XCUIApplication,
    labels: [String],
    fallbackX: CGFloat,
    fallbackY: CGFloat
  ) {
    for label in labels {
      if app.buttons[label].waitForExistence(timeout: 2) {
        app.buttons[label].tap()
        return
      }
      if app.staticTexts[label].waitForExistence(timeout: 1) {
        app.staticTexts[label].tap()
        return
      }
    }

    tap(app: app, x: fallbackX, y: fallbackY)
  }

  private func ask(_ question: String, label: String, in tag: XCUIApplication) {
    if tag.textViews.firstMatch.waitForExistence(timeout: 5) {
      tag.textViews.firstMatch.tap()
      tag.typeText(question)
    } else if tag.textFields.firstMatch.waitForExistence(timeout: 5) {
      tag.textFields.firstMatch.tap()
      tag.typeText(question)
    } else {
      tap(app: tag, x: 0.42, y: 0.92)
      tag.typeText(question)
    }

    sleep(1)
    attachScreenshot(named: "chat-matrix-\(label)-entered")

    tap(app: tag, x: 0.89, y: 0.92)

    sleep(2)
    attachScreenshot(named: "chat-matrix-\(label)-loading")
    sleep(50)
    attachScreenshot(named: "chat-matrix-\(label)-answer")
  }

  private func askFast(_ question: String, label: String, in tag: XCUIApplication) {
    if tag.textViews.firstMatch.waitForExistence(timeout: 5) {
      tag.textViews.firstMatch.tap()
      tag.typeText(question)
    } else if tag.textFields.firstMatch.waitForExistence(timeout: 5) {
      tag.textFields.firstMatch.tap()
      tag.typeText(question)
    } else {
      tap(app: tag, x: 0.42, y: 0.92)
      tag.typeText(question)
    }

    attachScreenshot(named: "chat-matrix-\(label)-entered")
    tap(app: tag, x: 0.89, y: 0.92)
    sleep(1)
    attachScreenshot(named: "chat-matrix-\(label)-loading")
    sleep(5)
    attachScreenshot(named: "chat-matrix-\(label)-answer")
  }

  private func tap(app: XCUIApplication, x: CGFloat, y: CGFloat) {
    app.coordinate(withNormalizedOffset: CGVector(dx: x, dy: y)).tap()
  }

  private func attachScreenshot(named name: String) {
    let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
    attachment.name = name
    attachment.lifetime = .keepAlways
    add(attachment)
  }
}
