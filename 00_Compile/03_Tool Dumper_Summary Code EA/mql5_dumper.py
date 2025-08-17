#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
MQL5 Project Dumper - Fixed Version
✅ Hỗ trợ đường dẫn tiếng Việt
✅ Hỗ trợ OneDrive paths  
✅ GUI chọn folder dễ dàng
"""

import os
import sys
from pathlib import Path
from datetime import datetime
import tkinter as tk
from tkinter import filedialog, messagebox
import threading

# Fix cho Unicode paths trên Windows
if sys.platform == 'win32':
    import locale
    locale.setlocale(locale.LC_ALL, 'vi_VN.UTF-8' if 'vi' in locale.getdefaultlocale()[0] else '')

class MQL5ProjectDumper:
    def __init__(self):
        # Các extension MQL cần gom
        self.mql_extensions = {'.mq5', '.mq4', '.mqh', '.ex5', '.ex4'}
        
        # Các thư mục cần bỏ qua
        self.skip_dirs = {
            '__pycache__', '.git', '.github', '.vscode', 'node_modules',
            'venv', 'env', '.env', 'dist', 'build', 'Debug', 'Release',
            'Logs', 'History', 'Tester', 'profiles', 'templates'
        }
        
        # Các file cần bỏ qua
        self.skip_files = {
            '.gitignore', '.gitattributes', 'README.md', 'LICENSE',
            '.DS_Store', 'Thumbs.db', 'desktop.ini'
        }
        
        self.processed_files = []
        self.total_lines = 0
        self.total_chars = 0

    def fix_path(self, path_str):
        """Fix đường dẫn có Unicode/tiếng Việt"""
        try:
            # Chuẩn hóa path
            if isinstance(path_str, str):
                # Xử lý OneDrive path đặc biệt
                path_str = path_str.replace('/', '\\')
                
                # Tạo Path object với encoding đúng
                path_obj = Path(path_str)
                
                # Kiểm tra tồn tại
                if not path_obj.exists():
                    # Thử với raw string
                    path_obj = Path(r"{}".format(path_str))
                
                return path_obj
            return Path(path_str)
        except Exception as e:
            print(f"⚠️ Lỗi xử lý đường dẫn: {e}")
            return Path(path_str)

    def should_skip_dir(self, dir_name):
        """Kiểm tra có nên bỏ qua thư mục không"""
        return dir_name.lower() in {d.lower() for d in self.skip_dirs}

    def should_skip_file(self, file_path):
        """Kiểm tra có nên bỏ qua file không"""
        file_name = file_path.name
        
        # Bỏ qua file trong danh sách skip
        if file_name in self.skip_files:
            return True
            
        # Bỏ qua file quá lớn (>50MB cho MQL)
        try:
            if file_path.stat().st_size > 50 * 1024 * 1024:
                return True
        except:
            pass
            
        return False

    def is_mql_file(self, file_path):
        """Kiểm tra có phải file MQL không"""
        return file_path.suffix.lower() in self.mql_extensions

    def is_text_file(self, file_path):
        """Kiểm tra có phải file text không"""
        text_extensions = {'.txt', '.md', '.rst', '.json', '.xml', '.yaml', '.yml', '.ini', '.cfg'}
        return file_path.suffix.lower() in text_extensions

    def generate_tree(self, root_path):
        """Tạo cây thư mục"""
        tree_lines = []
        
        def add_tree_item(path, prefix="", is_last=True):
            try:
                if self.should_skip_dir(path.name) or self.should_skip_file(path):
                    return
                    
                # Biểu tượng cây
                connector = "└── " if is_last else "├── "
                tree_lines.append(f"{prefix}{connector}{path.name}")
                
                if path.is_dir():
                    # Lấy danh sách file/folder con
                    try:
                        children = [p for p in path.iterdir() 
                                  if not self.should_skip_dir(p.name) and not self.should_skip_file(p)]
                        children.sort(key=lambda x: (x.is_file(), x.name.lower()))
                        
                        for i, child in enumerate(children):
                            is_last_child = (i == len(children) - 1)
                            next_prefix = prefix + ("    " if is_last else "│   ")
                            add_tree_item(child, next_prefix, is_last_child)
                    except (PermissionError, OSError) as e:
                        tree_lines.append(f"{prefix}    ⚠️ Không thể đọc: {e}")
            except Exception as e:
                tree_lines.append(f"{prefix}⚠️ Lỗi: {e}")

        add_tree_item(root_path)
        return "\n".join(tree_lines)

    def read_file_content(self, file_path):
        """Đọc nội dung file với nhiều encoding"""
        encodings = ['utf-8', 'utf-8-sig', 'utf-16', 'cp1252', 'latin-1', 'gbk', 'cp1250']
        
        for encoding in encodings:
            try:
                with open(str(file_path), 'r', encoding=encoding) as f:
                    content = f.read()
                    return content, encoding
            except (UnicodeDecodeError, UnicodeError):
                continue
            except Exception as e:
                return f"❌ Lỗi đọc file: {str(e)}", "error"
        
        # Thử đọc binary và decode
        try:
            with open(str(file_path), 'rb') as f:
                content_bytes = f.read()
                # Thử detect encoding
                import chardet
                detected = chardet.detect(content_bytes)
                if detected['encoding']:
                    content = content_bytes.decode(detected['encoding'])
                    return content, detected['encoding']
        except:
            pass
        
        return "❌ Không thể đọc file (encoding không hỗ trợ)", "error"

    def safe_walk(self, path):
        """os.walk an toàn với Unicode paths"""
        try:
            for root, dirs, files in os.walk(str(path)):
                # Convert về Path objects
                root_path = Path(root)
                dir_paths = [root_path / d for d in dirs]
                file_paths = [root_path / f for f in files]
                
                yield root_path, dir_paths, file_paths
        except Exception as e:
            print(f"⚠️ Lỗi duyệt thư mục: {e}")
            yield path, [], []

    def process_project(self, project_path, output_dir=None, progress_callback=None):
        """Xử lý toàn bộ project với Unicode support"""
        # Fix path
        project_path = self.fix_path(project_path)
        
        if not project_path.exists():
            error_msg = f"❌ Đường dẫn không tồn tại: {project_path}"
            print(error_msg)
            if progress_callback:
                progress_callback(error_msg)
            return False
            
        print(f"🔍 Đang phân tích project: {project_path.name}")
        print(f"📂 Đường dẫn: {project_path}")
        
        if progress_callback:
            progress_callback(f"Đang phân tích: {project_path.name}")
        
        # Xác định thư mục output (ưu tiên: tham số -> env var -> thư mục project)
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        try:
            # output_dir có thể được truyền qua tham số (CLI/GUI internal) hoặc ENV
            env_out = os.environ.get('MQL5_DUMPER_OUTPUT_DIR', '').strip()
        except Exception:
            env_out = ''
        
        if output_dir:
            output_base = self.fix_path(output_dir)
        elif env_out:
            output_base = self.fix_path(env_out)
        else:
            output_base = project_path
        
        # Tạo thư mục output nếu chưa tồn tại, fallback về project nếu lỗi
        try:
            output_base.mkdir(parents=True, exist_ok=True)
        except Exception as e:
            print(f"⚠️ Không thể tạo thư mục output '{output_base}': {e}")
            output_base = project_path
        
        output_file = output_base / f"EA_SOURCE_DUMP_{timestamp}.txt"
        
        try:
            with open(str(output_file), 'w', encoding='utf-8-sig') as f:  # utf-8-sig để Excel đọc được
                # Header
                f.write("=" * 80 + "\n")
                f.write(f"🚀 MQL5/MQL4 PROJECT DUMP\n")
                f.write(f"📅 Tạo lúc: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
                f.write(f"📂 Project: {project_path.name}\n")
                f.write(f"📍 Path: {project_path}\n")
                f.write("=" * 80 + "\n\n")
                
                # Cây thư mục
                f.write("📁 CẤU TRÚC THƯ MỤC\n")
                f.write("-" * 50 + "\n")
                
                if progress_callback:
                    progress_callback("Đang tạo cây thư mục...")
                    
                tree = self.generate_tree(project_path)
                f.write(tree + "\n\n")
                
                # Danh sách file MQL
                mql_files = []
                other_files = []
                
                if progress_callback:
                    progress_callback("Đang tìm file MQL...")
                
                # Duyệt thư mục an toàn
                for root_path, dir_paths, file_paths in self.safe_walk(project_path):
                    for file_path in file_paths:
                        if self.should_skip_file(file_path):
                            continue
                            
                        if self.is_mql_file(file_path):
                            mql_files.append(file_path)
                        elif self.is_text_file(file_path):
                            other_files.append(file_path)
                
                # Sắp xếp file
                mql_files.sort()
                other_files.sort()
                
                # Xử lý file MQL
                if mql_files:
                    f.write("📋 FILE MQL5/MQL4 (CHÍNH)\n")
                    f.write("=" * 50 + "\n\n")
                    
                    for idx, file_path in enumerate(mql_files):
                        if progress_callback:
                            progress_callback(f"Đang xử lý: {file_path.name} ({idx+1}/{len(mql_files)})")
                        
                        try:
                            rel_path = file_path.relative_to(project_path)
                        except:
                            rel_path = file_path.name
                            
                        f.write(f"📄 File: {rel_path}\n")
                        f.write(f"🔗 Đường dẫn đầy đủ: {file_path}\n")
                        f.write("-" * 40 + "\n")
                        
                        content, encoding = self.read_file_content(file_path)
                        
                        if encoding != "error":
                            lines = content.count('\n') + 1
                            chars = len(content)
                            self.total_lines += lines
                            self.total_chars += chars
                            
                            f.write(f"📊 Thống kê: {lines} dòng, {chars} ký tự, encoding: {encoding}\n\n")
                            # Ghi nội dung kèm số dòng
                            for line_no, line_txt in enumerate(content.splitlines(keepends=True), start=1):
                                f.write(f"{line_no:5d} | {line_txt}")
                            f.write("\n" + "=" * 80 + "\n\n")
                            
                            self.processed_files.append(str(rel_path))
                        else:
                            f.write(f"⚠️ {content}\n\n")
                
                # Xử lý file khác
                if other_files:
                    f.write("📋 FILE HỖ TRỢ KHÁC\n")
                    f.write("=" * 50 + "\n\n")
                    
                    for file_path in other_files[:10]:
                        try:
                            rel_path = file_path.relative_to(project_path)
                        except:
                            rel_path = file_path.name
                            
                        f.write(f"📄 File: {rel_path}\n")
                        f.write("-" * 40 + "\n")
                        
                        content, encoding = self.read_file_content(file_path)
                        
                        if encoding != "error" and len(content) < 10000:
                            f.write(content[:2000])
                            if len(content) > 2000:
                                f.write("\n\n... (file quá dài, đã cắt bớt) ...")
                            f.write("\n\n" + "-" * 40 + "\n\n")
                
                # Thống kê cuối
                f.write("📊 THỐNG KÊ TỔNG KẾT\n")
                f.write("=" * 50 + "\n")
                f.write(f"✅ File MQL đã xử lý: {len(mql_files)}\n")
                f.write(f"📄 File hỗ trợ: {len(other_files)}\n")
                f.write(f"📝 Tổng dòng code: {self.total_lines:,}\n")
                f.write(f"💾 Tổng ký tự: {self.total_chars:,}\n")
                f.write(f"📁 Kích thước output: {output_file.stat().st_size / 1024:.1f} KB\n")
                f.write("\n🎉 HOÀN THÀNH! File dump đã sẵn sàng cho AI phân tích!\n")
            
            if progress_callback:
                progress_callback("✅ Hoàn thành!")
                
            return output_file
            
        except Exception as e:
            error_msg = f"❌ Lỗi tạo file: {e}"
            print(error_msg)
            if progress_callback:
                progress_callback(error_msg)
            return False

class MQL5DumperGUI:
    """GUI cho MQL5 Dumper"""
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("🚀 MQL5 Project Dumper")
        self.root.geometry("600x400")
        
        # Center window
        self.root.update_idletasks()
        x = (self.root.winfo_screenwidth() // 2) - (300)
        y = (self.root.winfo_screenheight() // 2) - (200)
        self.root.geometry(f'+{x}+{y}')
        
        self.dumper = MQL5ProjectDumper()
        self.setup_gui()
        
    def setup_gui(self):
        """Setup GUI elements"""
        # Main frame
        main_frame = tk.Frame(self.root, padx=20, pady=20)
        main_frame.pack(fill='both', expand=True)
        
        # Title
        title = tk.Label(main_frame, text="MQL5 Project Dumper", 
                        font=('Arial', 18, 'bold'))
        title.pack(pady=(0, 20))
        
        # Description
        desc = tk.Label(main_frame, 
                       text="Gom tất cả file MQL5/MQL4 thành 1 file để AI phân tích",
                       font=('Arial', 10))
        desc.pack(pady=(0, 20))
        
        # Path frame
        path_frame = tk.Frame(main_frame)
        path_frame.pack(fill='x', pady=(0, 20))
        
        tk.Label(path_frame, text="Project Path:").pack(side='left')
        
        self.path_var = tk.StringVar()
        self.path_entry = tk.Entry(path_frame, textvariable=self.path_var, width=40)
        self.path_entry.pack(side='left', padx=10, fill='x', expand=True)
        
        browse_btn = tk.Button(path_frame, text="Browse...", command=self.browse_folder)
        browse_btn.pack(side='left')
        
        # Buttons
        btn_frame = tk.Frame(main_frame)
        btn_frame.pack(pady=20)
        
        self.process_btn = tk.Button(btn_frame, text="🚀 Start Dump", 
                                    command=self.process_project,
                                    bg='#4CAF50', fg='white',
                                    font=('Arial', 12, 'bold'),
                                    padx=20, pady=10)
        self.process_btn.pack()
        
        # Status
        self.status_label = tk.Label(main_frame, text="Ready", 
                                   font=('Arial', 10), fg='gray')
        self.status_label.pack(pady=10)
        
        # Result text
        text_frame = tk.Frame(main_frame)
        text_frame.pack(fill='both', expand=True)
        
        self.result_text = tk.Text(text_frame, height=10, width=60)
        self.result_text.pack(side='left', fill='both', expand=True)
        
        scrollbar = tk.Scrollbar(text_frame, command=self.result_text.yview)
        scrollbar.pack(side='right', fill='y')
        self.result_text.config(yscrollcommand=scrollbar.set)
    
    def browse_folder(self):
        """Chọn folder với Unicode support"""
        folder = filedialog.askdirectory(
            title="Chọn thư mục project MQL5/MQL4",
            initialdir=os.path.expanduser("~")
        )
        if folder:
            self.path_var.set(folder)
    
    def update_status(self, message):
        """Update status trong GUI thread"""
        self.root.after(0, lambda: self.status_label.config(text=message))
    
    def process_project(self):
        """Xử lý project trong thread riêng"""
        project_path = self.path_var.get().strip()
        
        if not project_path:
            messagebox.showwarning("Warning", "Vui lòng chọn thư mục project!")
            return
        
        # Disable button
        self.process_btn.config(state='disabled')
        self.result_text.delete(1.0, tk.END)
        
        # Run in thread
        def run():
            try:
                output_file = self.dumper.process_project(project_path, progress_callback=self.update_status)
                
                if output_file:
                    result = f"✅ THÀNH CÔNG!\n\n"
                    result += f"📄 File đã tạo: {output_file}\n"
                    result += f"📊 Đã xử lý {len(self.dumper.processed_files)} file MQL\n"
                    result += f"📝 Tổng cộng {self.dumper.total_lines:,} dòng code\n\n"
                    result += "🤖 Bây giờ bạn có thể copy nội dung file dump\n"
                    result += "   và paste cho AI để phân tích toàn bộ project!"
                    
                    self.root.after(0, lambda: self.result_text.insert(1.0, result))
                    self.root.after(0, lambda: messagebox.showinfo("Success", "Dump project thành công!"))
                else:
                    self.root.after(0, lambda: messagebox.showerror("Error", "Có lỗi xảy ra!"))
                    
            except Exception as e:
                self.root.after(0, lambda: messagebox.showerror("Error", f"Lỗi: {str(e)}"))
            finally:
                self.root.after(0, lambda: self.process_btn.config(state='normal'))
        
        threading.Thread(target=run, daemon=True).start()
    
    def run(self):
        """Run GUI"""
        self.root.mainloop()

def main():
    """Main function với GUI hoặc CLI"""
    if len(sys.argv) > 1:
        # CLI mode
        print("🚀 MQL5 PROJECT DUMPER")
        print("=" * 50)
        
        project_path = sys.argv[1]
        out_dir = sys.argv[2] if len(sys.argv) > 2 else None
        dumper = MQL5ProjectDumper()
        output_file = dumper.process_project(project_path, output_dir=out_dir)
        
        if output_file:
            print(f"\n✅ THÀNH CÔNG!")
            print(f"📄 File đã tạo: {output_file}")
            print(f"📊 Đã xử lý {len(dumper.processed_files)} file MQL")
    else:
        # GUI mode
        try:
            # Thử cài chardet nếu chưa có
            try:
                import chardet
            except ImportError:
                print("Installing chardet for better encoding detection...")
                os.system("pip install chardet")
            
            app = MQL5DumperGUI()
            app.run()
        except Exception as e:
            print(f"❌ Lỗi GUI: {e}")
            print("\nChạy mode console:")
            project_path = input("📂 Nhập đường dẫn project EA: ").strip('"')
            
            if project_path:
                dumper = MQL5ProjectDumper()
                dumper.process_project(project_path)

if __name__ == "__main__":
    main()