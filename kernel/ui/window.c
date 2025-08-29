struct Window {
    int x, y, w, h;
    char* title;
    void (*paint)(struct Window*);
};

void paint_window(struct Window* win) {
    // Draw border (macOS-like: thin gray)
    // Fill background (white)
    // Draw title bar (blue gradient for KDE feel)
    // Add shadow: Blur around edges
}
