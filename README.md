# 🚀 .NET Developer Suite - All-in-One Installer

Script tự động hóa việc tải và thiết lập môi trường phát triển cho .NET Developer trên Windows. Không cần tìm link tải thủ công, không cần setup phức tạp.

**Author:** TuanCter

## ✨ Tính năng
* ✅ **Tự động kiểm tra quyền Admin** (Tự động xin quyền nếu chưa có).
* ✅ **Tự động tạo thư mục lưu trữ** tại `C:\Installers`.
* ✅ **Tải phiên bản ổn định mới nhất** của các công cụ thiết yếu.

## 📦 Danh sách phần mềm hỗ trợ
Script sẽ tự động tải các công cụ sau:
1.  **Visual Studio Code** (System Installer)
2.  **Git** (Latest Version)
3.  **Visual Studio Installer** (Community 2022)
4.  **Docker Desktop**
5.  **pgAdmin 4**
6.  **Cursor** (AI Code Editor)
7.  **DBeaver Community**
8.  **NodeJS** (LTS Version)

---

## ⚡ Hướng dẫn cài đặt nhanh (Quick Start)

Bạn chỉ cần mở **PowerShell** và chạy **duy nhất một dòng lệnh** dưới đây:

```powershell
irm [https://raw.githubusercontent.com/tuancter/NET_Developer_Suite/refs/heads/master/All_in_one.ps1](https://raw.githubusercontent.com/tuancter/NET_Developer_Suite/refs/heads/master/All_in_one.ps1) | iex
