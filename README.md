## Status
⚠️ This project is currently under active development (Work in Progress).

Kotobee is a Japanese learning application designed for both students who study Japanese and teachers who monitor learning progress.
The application was developed by a team over a period of approximately three months.

I was mainly responsible for implementing the grammar game, stage selection screen, and the teacher dashboard.
By adopting a game-based learning approach, the application aims to keep students motivated and support continuous learning.

Initially, the system was designed as a web-only application for both students and teachers.
However, I proposed introducing a mobile application to improve accessibility for students.
As a result, the student-facing application is currently being developed and delivered as a mobile app using Flutter.

## Screenshots (Mobile App)

### Stage Selection
<p align="center">
  <img src="assets/screenshots/stage_select.png" width="300" />
</p>

<table align="center">
  <tr>
    <td align="center">
      <img src="assets/screenshots/kana_game.png" width="230" /><br>
      <b>Kana Game</b>
    </td>
    <td align="center">
      <img src="assets/screenshots/vocabulary_game.png" width="230" /><br>
      <b>Vocabulary Game</b>
    </td>
    <td align="center">
      <img src="assets/screenshots/grammar_game.png" width="230" /><br>
      <b>Grammar Game</b>
    </td>
  </tr>
</table>

## Implemented Features
- Three learning games for studying Japanese:
  - Kana
  - Vocabulary
  - Grammar
- Web dashboard for teachers to monitor students’ learning progress
- User authentication (login)
- Payment system

## Planned Features and Improvements
- More robust authentication system (Google login and email-based login)
- UI/UX improvements for both mobile and web applications
- Code refactoring and overall codebase cleanup
- Chat functionality between students and teachers
- Bug fixes and minor stability improvements

## Tech Stack
- Flutter (Mobile Application)
- Laravel (Backend API and Web Application)

## Project Structure
- `mobile_flutter/` : Flutter-based mobile application for learners  
- `web_laravel/`   : Laravel backend API and teacher web dashboard  

## Note
This project is still evolving, and some parts of the implementation require further refinement.
I am continuously improving the codebase, enhancing the UI/UX, and addressing known issues to increase overall quality and maintainability.
