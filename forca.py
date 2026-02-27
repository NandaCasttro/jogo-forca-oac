import os
import queue
import subprocess
import threading
import tkinter as tk
from tkinter import ttk, messagebox

MARS_JAR = r"D:\W11\DOWNLOADS\Mars4_5.jar"
ASM_FILE = "jogo-forca-oac.asm"


class ForcaUI:
    def __init__(self, root: tk.Tk) -> None:
        self.root = root
        self.root.title("Jogo da Forca - OAC")
        self.root.attributes('-fullscreen', True)
        self.root.configure(bg="#2c3e50")
        self.root.bind("<Escape>", lambda e: self.root.attributes('-fullscreen', False))
        self.root.bind("<F11>", lambda e: self.root.attributes('-fullscreen', True))
        self.proc = None
        self.output_queue: queue.Queue[str | None] = queue.Queue()
        self.reader_thread = None
        self.output_buffer = ""

        self.hint_var = tk.StringVar(value="")
        self.word_var = tk.StringVar(value="")
        self.errors_var = tk.StringVar(value="0/6")
        self.used_var = tk.StringVar(value="")
        self.status_var = tk.StringVar(value="")
        self.answer_var = tk.StringVar(value="")
        self.last_letter_var = tk.StringVar(value="")
        self.current_input_var = tk.StringVar(value="")
        
        self.correct_letters = set()
        self.incorrect_letters = set()
        self.current_errors = 0

        self._setup_styles()

        self.start_frame = tk.Frame(self.root, bg="#2c3e50")
        self.start_frame.pack(fill="both", expand=True)

        # Container central
        center_container = tk.Frame(self.start_frame, bg="#34495e", relief="flat")
        center_container.place(relx=0.5, rely=0.5, anchor="center")
        
        title = tk.Label(center_container, text="🎮 JOGO DA FORCA", 
                        font=("Arial", 32, "bold"), bg="#34495e", fg="#ecf0f1", pady=20)
        title.pack()
        
        subtitle = tk.Label(center_container, text="Organização e Arquitetura de Computadores",
                           font=("Arial", 11), bg="#34495e", fg="#95a5a6", pady=5)
        subtitle.pack()

        desc = tk.Label(center_container, text="Descubra a palavra antes de 6 erros!",
                       font=("Arial", 12), bg="#34495e", fg="#bdc3c7", pady=15)
        desc.pack()

        play_btn = tk.Button(center_container, text="▶ JOGAR", command=self.start_game,
                            font=("Arial", 14, "bold"), bg="#27ae60", fg="white",
                            activebackground="#229954", activeforeground="white",
                            relief="flat", padx=40, pady=15, cursor="hand2",
                            borderwidth=0)
        play_btn.pack(pady=20)

        self.game_frame = tk.Frame(self.root, bg="#2c3e50")
        
        # Container superior com canvas e info
        top_container = tk.Frame(self.game_frame, bg="#2c3e50")
        
        # Canvas para desenhar a forca
        canvas_frame = tk.Frame(top_container, bg="#34495e", relief="ridge", bd=2)
        self.canvas = tk.Canvas(canvas_frame, width=220, height=270, bg="#ecf0f1", highlightthickness=0)
        
        # Frame de informações do jogo
        info_frame = tk.Frame(top_container, bg="#34495e", relief="ridge", bd=2, padx=20, pady=20)
        
        self.hint_label = tk.Label(info_frame, textvariable=self.hint_var, 
                                   font=("Arial", 13, "bold"), bg="#34495e", fg="#f39c12", anchor="w")
        
        self.word_label = tk.Label(info_frame, textvariable=self.word_var, 
                                   font=("Consolas", 24, "bold"), bg="#34495e", fg="#ecf0f1", pady=15)
        
        self.errors_label = tk.Label(info_frame, textvariable=self.errors_var, 
                                     font=("Arial", 11, "bold"), bg="#34495e", fg="#e74c3c", anchor="w")
        
        self.used_letters_frame = tk.Frame(info_frame, bg="#34495e")
        self.used_letters_title = tk.Label(self.used_letters_frame, text="Letras: ", 
                                          font=("Arial", 10, "bold"), bg="#34495e", fg="#bdc3c7")
        
        # Container inferior com input
        bottom_container = tk.Frame(self.game_frame, bg="#34495e", relief="ridge", bd=2, pady=15)
        
        self.status_label = tk.Label(bottom_container, textvariable=self.status_var, 
                                     font=("Arial", 11, "italic"), bg="#34495e", fg="#3498db")
        
        input_frame = tk.Frame(bottom_container, bg="#34495e")
        
        self.entry = tk.Entry(input_frame, width=3, font=("Arial", 20, "bold"), 
                             justify="center", relief="solid", bd=2, bg="#ecf0f1", fg="#2c3e50")
        self.entry.bind("<KeyRelease>", self.on_typing)
        self.entry.bind("<Return>", self.on_enter)
        
        self.send_btn = tk.Button(input_frame, text="✓ Enviar", command=self.send_letter,
                                 font=("Arial", 12, "bold"), bg="#3498db", fg="white",
                                 activebackground="#2980b9", activeforeground="white",
                                 relief="flat", padx=20, pady=10, cursor="hand2")
        
        self.current_input_label = tk.Label(bottom_container, textvariable=self.current_input_var, 
                                           font=("Arial", 9), bg="#34495e", fg="#95a5a6")
        
        self.answer_label = tk.Label(bottom_container, textvariable=self.answer_var, 
                                     font=("Arial", 12, "bold"), bg="#34495e", fg="#9b59b6")
        
        self.last_letter_label = tk.Label(info_frame, textvariable=self.last_letter_var, 
                                         font=("Arial", 9), bg="#34495e", fg="#7f8c8d", anchor="w")

        self._layout_game()
        self.root.protocol("WM_DELETE_WINDOW", self.on_close)

    def _layout_game(self) -> None:
        # Layout do container superior
        top_container = self.canvas.master.master
        top_container.pack(fill="both", expand=True, padx=15, pady=(15, 8))
        
        # Canvas à esquerda
        canvas_frame = self.canvas.master
        canvas_frame.pack(side="left", padx=(0, 10))
        self.canvas.pack(padx=10, pady=10)
        
        # Info à direita
        info_frame = self.hint_label.master
        info_frame.pack(side="left", fill="both", expand=True)
        
        self.hint_label.pack(anchor="w", pady=(0, 10))
        self.word_label.pack(anchor="center", pady=5)
        self.errors_label.pack(anchor="w", pady=(10, 5))
        
        self.used_letters_frame.pack(anchor="w", pady=(5, 5), fill="x")
        self.used_letters_title.pack(side="left")
        
        self.last_letter_label.pack(anchor="w", pady=(10, 0))
        
        # Layout do container inferior
        bottom_container = self.status_label.master
        bottom_container.pack(fill="x", padx=15, pady=(0, 15))
        
        self.status_label.pack(pady=(10, 10))
        
        input_frame = self.entry.master
        input_frame.pack(pady=5)
        self.entry.pack(side="left", padx=(0, 10))
        self.send_btn.pack(side="left")
        
        self.current_input_label.pack(pady=(5, 5))
        self.answer_label.pack(pady=(5, 10))

    def _setup_styles(self) -> None:
        pass  # Estilos agora são aplicados diretamente nos widgets

    def start_game(self) -> None:
        self.start_frame.pack_forget()
        self.game_frame.pack(fill="both", expand=True)
        self._reset_ui_state()
        self._start_process()

    def _reset_ui_state(self) -> None:
        self.hint_var.set("Dica: ")
        self.word_var.set("")
        self.errors_var.set("0/6")
        self.status_var.set("Aguardando...")
        self.answer_var.set("")
        self.last_letter_var.set("Ultima letra: -")
        self.current_input_var.set("Digitando: ")
        self.correct_letters.clear()
        self.incorrect_letters.clear()
        self.current_errors = 0
        self._update_used_letters_display()
        self._draw_hangman(0)
        self.entry.delete(0, "end")
        self.entry.configure(state="normal")
        self.send_btn.configure(state="normal")
        self.entry.focus_set()

    def _start_process(self) -> None:
        repo_dir = os.path.dirname(os.path.abspath(__file__))
        cmd = ["java", "-jar", MARS_JAR, "nc", ASM_FILE]
        self.proc = subprocess.Popen(
            cmd,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
            cwd=repo_dir,
        )
        self.reader_thread = threading.Thread(target=self._read_output, daemon=True)
        self.reader_thread.start()
        self.root.after(50, self._poll_output)

    def _read_output(self) -> None:
        assert self.proc is not None
        assert self.proc.stdout is not None
        while True:
            chunk = self.proc.stdout.read(1)
            if chunk == "":
                break
            self.output_queue.put(chunk)
        self.output_queue.put(None)

    def _poll_output(self) -> None:
        try:
            while True:
                chunk = self.output_queue.get_nowait()
                if chunk is None:
                    self._end_game("Processo encerrado")
                    break
                self.output_buffer += chunk
        except queue.Empty:
            pass

        self._process_buffer()

        if self.proc is not None and self.proc.poll() is None:
            self.root.after(50, self._poll_output)
        else:
            self._end_game("Processo encerrado")

    def _process_buffer(self) -> None:
        normalized = self.output_buffer.replace("\r", "\n")
        self.output_buffer = ""

        while "\n" in normalized:
            line, normalized = normalized.split("\n", 1)
            self._handle_line(line)

        if "Digite uma letra:" in normalized:
            self._handle_line("Digite uma letra:")
            normalized = normalized.replace("Digite uma letra:", "")

        self.output_buffer = normalized

    def _handle_line(self, line: str) -> None:
        text = line.strip("\r\n")
        if not text:
            return

        if text.startswith("Dica:"):
            self.hint_var.set(text)
            return
        if text.startswith("Erros:"):
            errors_text = text.replace("Erros:", "Erros: ").strip()
            self.errors_var.set(errors_text)
            try:
                new_errors = int(errors_text.split(":")[1].split("/")[0].strip())
                self.current_errors = new_errors
                self._draw_hangman(new_errors)
            except:
                pass
            return
        if text.startswith("Letras usadas:"):
            letters = text.replace("Letras usadas:", "").strip()
            if letters:
                last_letter = letters[-1]
                self.last_letter_var.set(f"Ultima letra: {last_letter}")
            return
        if text.startswith("VITORIA"):
            self.status_var.set("VITORIA! 🎉")
            return
        if text.startswith("DERROTA"):
            self.status_var.set("DERROTA 😢")
            return
        if text.startswith("A palavra era:"):
            palavra = text.replace("A palavra era:", "").strip()
            self.answer_var.set(text)
            self.entry.configure(state="disabled")
            self.send_btn.configure(state="disabled")
            
            # Mostrar popup com resultado
            if "VITORIA" in self.status_var.get():
                messagebox.showinfo(
                    "🎉 Parabéns!",
                    f"Você acertou a palavra!\n\n✨ {palavra.upper()} ✨\n\nVitória!"
                )
            elif "DERROTA" in self.status_var.get():
                messagebox.showwarning(
                    "😢 Que pena!",
                    f"Você perdeu!\n\nA palavra era: {palavra.upper()}\n\nTente novamente!"
                )
            return
        if text.startswith("Digite uma letra:"):
            self.status_var.set("Digite uma letra e pressione Enter")
            self.entry.focus_set()
            return

        if ":" in text or text.startswith("===") or text.startswith("Jogador"):
            return

        if any(ch.isalpha() or ch == "_" for ch in text):
            self.word_var.set(text)

    def on_enter(self, _event: tk.Event) -> None:
        self.send_letter()

    def on_typing(self, _event: tk.Event) -> None:
        value = self.entry.get().strip()
        if value:
            self.current_input_var.set(f"Digitando: {value}")
        else:
            self.current_input_var.set("Digitando: ")

    def send_letter(self) -> None:
        if self.proc is None or self.proc.stdin is None:
            return

        value = self.entry.get().strip()
        if not value:
            return

        letter = value[0].lower()
        if not letter.isalpha():
            return

        # Armazenar erros atuais antes de enviar
        errors_before = self.current_errors

        self.entry.delete(0, "end")
        self.current_input_var.set("Digitando: ")
        self.last_letter_var.set(f"Ultima letra: {letter}")
        
        try:
            self.proc.stdin.write(letter + "\n")
            self.proc.stdin.flush()
            
            # Agendar verificação após um curto delay para permitir atualização
            self.root.after(100, lambda: self._classify_letter(letter, errors_before))
        except Exception:
            self._end_game("Falha ao enviar letra")

    def _classify_letter(self, letter: str, errors_before: int) -> None:
        """Classifica a letra como correta (verde) ou incorreta (vermelha) baseado nos erros."""
        if self.current_errors > errors_before:
            # Erro aumentou = letra incorreta
            self.incorrect_letters.add(letter)
            self.correct_letters.discard(letter)
        else:
            # Erro não aumentou = letra correta
            self.correct_letters.add(letter)
            self.incorrect_letters.discard(letter)
        
        self._update_used_letters_display()
    
    def _update_used_letters_display(self) -> None:
        """Atualiza a exibição das letras usadas com cores."""
        # Limpar labels anteriores
        for widget in self.used_letters_frame.winfo_children():
            if widget != self.used_letters_title:
                widget.destroy()
        
        # Adicionar letras corretas (verde)
        for letter in sorted(self.correct_letters):
            label = tk.Label(
                self.used_letters_frame,
                text=letter.upper(),
                font=("Arial", 11, "bold"),
                bg="#27ae60",
                fg="white",
                padx=6,
                pady=2,
                relief="raised",
                bd=1
            )
            label.pack(side="left", padx=2)
        
        # Adicionar letras incorretas (vermelho)
        for letter in sorted(self.incorrect_letters):
            label = tk.Label(
                self.used_letters_frame,
                text=letter.upper(),
                font=("Arial", 11, "bold"),
                bg="#e74c3c",
                fg="white",
                padx=6,
                pady=2,
                relief="raised",
                bd=1
            )
            label.pack(side="left", padx=2)
    
    def _draw_hangman(self, errors: int) -> None:
        """Desenha a forca e o boneco baseado no número de erros."""
        self.canvas.delete("all")
        
        # Cor da estrutura
        structure_color = "#8b4513"
        person_color = "#2c3e50"
        
        # Desenhar a estrutura da forca (sempre visível)
        # Base
        self.canvas.create_rectangle(20, 240, 140, 250, fill=structure_color, outline=structure_color)
        # Poste vertical
        self.canvas.create_rectangle(60, 40, 70, 240, fill=structure_color, outline=structure_color)
        # Poste horizontal
        self.canvas.create_rectangle(60, 40, 160, 50, fill=structure_color, outline=structure_color)
        # Corda
        self.canvas.create_line(150, 50, 150, 80, width=3, fill="#7f8c8d")
        
        # Desenhar partes do boneco baseado nos erros
        if errors >= 1:
            # Cabeça
            self.canvas.create_oval(125, 80, 175, 130, outline=person_color, width=3, fill="#f39c12")
            # Olhos tristes
            self.canvas.create_oval(135, 95, 143, 103, fill=person_color)
            self.canvas.create_oval(157, 95, 165, 103, fill=person_color)
            # Boca triste
            self.canvas.create_arc(135, 105, 165, 125, start=0, extent=-180, width=2, outline=person_color, style="arc")
        
        if errors >= 2:
            # Tronco
            self.canvas.create_line(150, 130, 150, 190, width=4, fill=person_color)
        
        if errors >= 3:
            # Braço esquerdo
            self.canvas.create_line(150, 145, 120, 165, width=3, fill=person_color)
        
        if errors >= 4:
            # Braço direito
            self.canvas.create_line(150, 145, 180, 165, width=3, fill=person_color)
        
        if errors >= 5:
            # Perna esquerda
            self.canvas.create_line(150, 190, 130, 230, width=3, fill=person_color)
        
        if errors >= 6:
            # Perna direita
            self.canvas.create_line(150, 190, 170, 230, width=3, fill=person_color)
            # X nos olhos quando perde
            self.canvas.create_line(135, 95, 143, 103, width=2, fill="#e74c3c")
            self.canvas.create_line(143, 95, 135, 103, width=2, fill="#e74c3c")
            self.canvas.create_line(157, 95, 165, 103, width=2, fill="#e74c3c")
            self.canvas.create_line(165, 95, 157, 103, width=2, fill="#e74c3c")
    
    def _end_game(self, message: str) -> None:
        self.status_var.set(message)
        self.entry.configure(state="disabled")
        self.send_btn.configure(state="disabled")

    def on_close(self) -> None:
        if self.proc is not None and self.proc.poll() is None:
            try:
                self.proc.terminate()
            except Exception:
                pass
        self.root.destroy()


if __name__ == "__main__":
    root = tk.Tk()
    app = ForcaUI(root)
    root.mainloop()
