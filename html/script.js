// Chat UI Controller
class ChatUI {
    constructor() {
        this.container = document.getElementById('chatContainer');
        this.messagesDiv = document.getElementById('chatMessages');
        this.chatInput = document.getElementById('chatInput');
        this.sendBtn = document.getElementById('sendBtn');
        this.closeBtn = document.getElementById('closeBtn');
        this.chatTypeDisplay = document.getElementById('chatTypeDisplay');
        this.charCount = document.getElementById('charCount');
        this.charCounter = document.querySelector('.char-counter');
        this.dragHandle = document.getElementById('dragHandle');
        
        // Whisper elements
        this.whisperSection = document.getElementById('whisperSection');
        this.whisperInput = document.getElementById('whisperInput');
        this.whisperTarget = document.getElementById('whisperTarget');
        this.cancelWhisper = document.getElementById('cancelWhisper');
        
        // State
        this.currentChatType = 'local';
        this.isOpen = false;
        this.whisperTargetId = null;
        this.whisperTargetName = null;
        
        // Drag state
        this.isDragging = false;
        this.dragStartX = 0;
        this.dragStartY = 0;
        this.dragStartLeft = 0;
        this.dragStartTop = 0;
        
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.loadChatHistory();
        this.loadPosition();
    }

    setupEventListeners() {
        // Send message events
        this.sendBtn.addEventListener('click', () => this.sendMessage());
        this.chatInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                this.sendMessage();
            }
        });

        // ESC key to close chat
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && this.isOpen) {
                e.preventDefault();
                this.close();
            }
        });

        // Chat type selector
        document.querySelectorAll('.chat-type-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                document.querySelectorAll('.chat-type-btn').forEach(b => b.classList.remove('active'));
                btn.classList.add('active');
                this.currentChatType = btn.dataset.type;
                this.updateChatTypeDisplay();
                this.chatInput.focus();
            });
        });

        // Close button
        this.closeBtn.addEventListener('click', () => this.close());

        // Drag handlers
        this.dragHandle.addEventListener('mousedown', (e) => this.onDragStart(e));
        document.addEventListener('mousemove', (e) => this.onDragMove(e));
        document.addEventListener('mouseup', (e) => this.onDragEnd(e));

        // Character counter
        this.chatInput.addEventListener('input', () => {
            const count = this.chatInput.value.length;
            this.charCount.textContent = count;
            
            this.charCounter.classList.remove('warning', 'danger');
            if (count > 230) {
                this.charCounter.classList.add('danger');
            } else if (count > 200) {
                this.charCounter.classList.add('warning');
            }
        });

        // Whisper input
        this.cancelWhisper.addEventListener('click', () => this.cancelWhisperMode());
        this.whisperInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                e.preventDefault();
                this.sendWhisper();
            }
        });

        // Listen for messages from client script
        window.addEventListener('message', (event) => {
            const data = event.data;
            
            if (data.type === 'chat:open') {
                this.open();
            } else if (data.type === 'chat:close') {
                this.close();
            } else if (data.type === 'chat:message') {
                this.addMessage(data);
            } else if (data.type === 'chat:system') {
                this.addSystemMessage(data.message);
            } else if (data.type === 'chat:whisper') {
                this.startWhisperMode(data.targetId, data.targetName);
            }
        });
    }

    sendMessage() {
        const message = this.chatInput.value.trim();
        
        if (!message) {
            this.addSystemMessage('Message cannot be empty.');
            return;
        }

        // Send to client script
        fetch('https://rex-chat/sendMessage', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                chatType: this.currentChatType,
                message: message
            })
        });

        // Clear input
        this.chatInput.value = '';
        this.charCount.textContent = '0';
        this.chatInput.focus();
    }

    sendWhisper() {
        const message = this.whisperInput.value.trim();
        
        if (!message) {
            this.addSystemMessage('Message cannot be empty.');
            return;
        }

        fetch('https://rex-chat/sendWhisper', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                targetId: this.whisperTargetId,
                message: message
            })
        });

        // Clear and close whisper
        this.whisperInput.value = '';
        this.cancelWhisperMode();
        this.chatInput.focus();
    }

    startWhisperMode(targetId, targetName) {
        this.whisperTargetId = targetId;
        this.whisperTargetName = targetName;
        this.whisperTarget.textContent = targetName;
        this.whisperSection.style.display = 'flex';
        this.whisperInput.focus();
    }

    cancelWhisperMode() {
        this.whisperTargetId = null;
        this.whisperTargetName = null;
        this.whisperSection.style.display = 'none';
        this.chatInput.focus();
    }

    addMessage(data) {
        const messageEl = document.createElement('div');
        messageEl.className = 'chat-message';
        
        // Sender name
        const senderEl = document.createElement('div');
        senderEl.className = `message-sender ${data.chatType}`;
        senderEl.textContent = data.sender;
        
        // Message text
        const textEl = document.createElement('div');
        textEl.className = 'message-text';
        textEl.textContent = data.message;
        
        messageEl.appendChild(senderEl);
        messageEl.appendChild(textEl);
        
        // Add timestamp
        const timestamp = document.createElement('div');
        timestamp.className = 'timestamp';
        timestamp.textContent = this.getTimeString();
        messageEl.appendChild(timestamp);
        
        this.messagesDiv.appendChild(messageEl);
        this.autoScroll();
        
        // Keep message history manageable
        if (this.messagesDiv.children.length > 100) {
            this.messagesDiv.children[1].remove(); // Keep first child (system message)
        }
    }

    addSystemMessage(message) {
        const messageEl = document.createElement('div');
        messageEl.className = 'system-message';
        messageEl.textContent = message;
        
        this.messagesDiv.appendChild(messageEl);
        this.autoScroll();
    }

    updateChatTypeDisplay() {
        const labels = {
            'local': 'LOCAL',
            'shout': 'SHOUT',
            'ooc': 'OOC',
            'job': 'JOB',
            'admin': 'ADMIN'
        };
        
        this.chatTypeDisplay.textContent = labels[this.currentChatType] || 'LOCAL';
    }

    getTimeString() {
        const now = new Date();
        return now.toLocaleTimeString('en-US', { 
            hour: '2-digit', 
            minute: '2-digit',
            hour12: false
        });
    }

    autoScroll() {
        setTimeout(() => {
            this.messagesDiv.scrollTop = this.messagesDiv.scrollHeight;
        }, 10);
    }

    open() {
        if (this.isOpen) return;
        
        this.isOpen = true;
        this.container.classList.add('active');
        this.container.classList.remove('fade-out');
        this.chatInput.focus();
    }

    close() {
        if (!this.isOpen) return;
        
        this.isOpen = false;
        this.container.classList.add('fade-out');
        
        setTimeout(() => {
            this.container.classList.remove('active', 'fade-out');
        }, 300);

        // Tell client we're closing
        fetch('https://rex-chat/closeChat', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            }
        });
    }

    loadChatHistory() {
        // Request chat history from client
        fetch('https://rex-chat/getChatHistory', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            }
        });
    }

    loadPosition() {
        const savedPosition = localStorage.getItem('chatPosition');
        if (savedPosition) {
            try {
                const pos = JSON.parse(savedPosition);
                this.container.style.left = pos.left + 'px';
                this.container.style.top = pos.top + 'px';
            } catch (e) {
                console.error('Failed to load chat position:', e);
            }
        }
    }

    savePosition() {
        const rect = this.container.getBoundingClientRect();
        const position = {
            left: this.container.offsetLeft,
            top: this.container.offsetTop
        };
        localStorage.setItem('chatPosition', JSON.stringify(position));
    }

    onDragStart(e) {
        // Only drag from header area, not from buttons
        if (e.target.closest('button')) return;
        
        this.isDragging = true;
        this.dragStartX = e.clientX;
        this.dragStartY = e.clientY;
        this.dragStartLeft = this.container.offsetLeft;
        this.dragStartTop = this.container.offsetTop;
        
        this.container.style.cursor = 'grabbing';
        this.dragHandle.style.userSelect = 'none';
    }

    onDragMove(e) {
        if (!this.isDragging) return;
        
        const deltaX = e.clientX - this.dragStartX;
        const deltaY = e.clientY - this.dragStartY;
        
        const newLeft = this.dragStartLeft + deltaX;
        const newTop = this.dragStartTop + deltaY;
        
        // Keep within viewport bounds
        const maxLeft = window.innerWidth - this.container.offsetWidth;
        const maxTop = window.innerHeight - this.container.offsetHeight;
        
        const finalLeft = Math.max(0, Math.min(newLeft, maxLeft));
        const finalTop = Math.max(0, Math.min(newTop, maxTop));
        
        this.container.style.left = finalLeft + 'px';
        this.container.style.top = finalTop + 'px';
    }

    onDragEnd(e) {
        if (!this.isDragging) return;
        
        this.isDragging = false;
        this.container.style.cursor = 'default';
        this.dragHandle.style.userSelect = 'auto';
        
        this.savePosition();
    }
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', () => {
    window.chatUI = new ChatUI();
});
