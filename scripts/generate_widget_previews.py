import os
from PIL import Image, ImageDraw, ImageFont

# Create drawable-nodpi if not exists
out_dir = "/Users/hasangseon/three_sec_habit/android/app/src/main/res/drawable-nodpi"
os.makedirs(out_dir, exist_ok=True)

# Try to find a font or use default
try:
    font_title = ImageFont.truetype("/System/Library/Fonts/AppleSDGothicNeo.ttc", 24)
    font_bold = ImageFont.truetype("/System/Library/Fonts/AppleSDGothicNeo.ttc", 22)
    font_semi = ImageFont.truetype("/System/Library/Fonts/AppleSDGothicNeo.ttc", 18)
    font_regular = ImageFont.truetype("/System/Library/Fonts/AppleSDGothicNeo.ttc", 16)
    font_small = ImageFont.truetype("/System/Library/Fonts/AppleSDGothicNeo.ttc", 14)
    font_big = ImageFont.truetype("/System/Library/Fonts/AppleSDGothicNeo.ttc", 44)
except Exception:
    font_title = font_bold = font_semi = font_regular = font_small = font_big = ImageFont.load_default()

# -------------------------------------------------------------
# 1. Generate 4x2 Widget Preview (Width 640, Height 320)
# -------------------------------------------------------------
w4, h4 = 640, 320
img4 = Image.new("RGBA", (w4, h4), (0, 0, 0, 0))
draw4 = ImageDraw.Draw(img4)

# Outer card background (Dark rounded rect)
draw4.rounded_rectangle(
    [(10, 10), (w4 - 10, h4 - 10)],
    radius=28,
    fill=(24, 26, 32, 245),
    outline=(60, 64, 80, 255),
    width=2
)

# Header: App Title
draw4.text((36, 30), "⚡ 3초 습관 · 오늘 루틴", fill=(167, 139, 250, 255), font=font_title)

# Header: Progress Badge
badge_text = "2 / 3 완료 (67%)"
draw4.rounded_rectangle(
    [(w4 - 190, 28), (w4 - 36, 62)],
    radius=16,
    fill=(34, 197, 94, 38),
    outline=(34, 197, 94, 180),
    width=1
)
draw4.text((w4 - 176, 35), badge_text, fill=(34, 197, 94, 255), font=font_small)

# Divider
draw4.line([(36, 76), (w4 - 36, 76)], fill=(45, 48, 60, 255), width=1)

# Item 1: Done habit
draw4.rounded_rectangle([(36, 90), (w4 - 36, 146)], radius=16, fill=(32, 35, 44, 255), outline=(50, 54, 66, 255), width=1)
draw4.text((54, 104), "아침 미온수 한 잔 마시기", fill=(156, 163, 175, 255), font=font_semi)
# Done Checkbox
draw4.ellipse([(w4 - 82, 100), (w4 - 50, 132)], fill=(34, 197, 94, 255))
draw4.text((w4 - 72, 104), "✓", fill=(255, 255, 255, 255), font=font_semi)

# Item 2: Count habit
draw4.rounded_rectangle([(36, 158), (w4 - 36, 214)], radius=16, fill=(32, 35, 44, 255), outline=(50, 54, 66, 255), width=1)
draw4.text((54, 172), "물 8잔 마시기", fill=(243, 244, 246, 255), font=font_semi)
# Count chip
draw4.rounded_rectangle([(w4 - 170, 168), (w4 - 98, 202)], radius=10, fill=(99, 102, 241, 40), outline=(99, 102, 241, 150), width=1)
draw4.text((w4 - 158, 175), "5 / 8잔", fill=(167, 139, 250, 255), font=font_small)
# +1 Button
draw4.rounded_rectangle([(w4 - 86, 168), (w4 - 50, 202)], radius=10, fill=(99, 102, 241, 220))
draw4.text((w4 - 76, 174), "+1", fill=(255, 255, 255, 255), font=font_small)

# Item 3: Incomplete habit
draw4.rounded_rectangle([(36, 226), (w4 - 36, 282)], radius=16, fill=(32, 35, 44, 255), outline=(50, 54, 66, 255), width=1)
draw4.text((54, 240), "하루 30분 유산소 운동", fill=(243, 244, 246, 255), font=font_semi)
# Incomplete Check circle
draw4.ellipse([(w4 - 82, 236), (w4 - 50, 268)], fill=(40, 44, 56, 255), outline=(156, 163, 175, 200), width=2)

img4.save(os.path.join(out_dir, "widget_preview_4x2.png"), "PNG")
print("Saved widget_preview_4x2.png")

# -------------------------------------------------------------
# 2. Generate 2x2 Widget Preview (Width 360, Height 360)
# -------------------------------------------------------------
w2, h2 = 360, 360
img2 = Image.new("RGBA", (w2, h2), (0, 0, 0, 0))
draw2 = ImageDraw.Draw(img2)

# Outer card
draw2.rounded_rectangle(
    [(10, 10), (w2 - 10, h2 - 10)],
    radius=28,
    fill=(24, 26, 32, 245),
    outline=(60, 64, 80, 255),
    width=2
)

# Header
draw2.text((28, 28), "⚡ 3초 습관", fill=(167, 139, 250, 255), font=font_bold)
draw2.text((w2 - 70, 32), "오늘", fill=(156, 163, 175, 255), font=font_small)

# Center Progress
draw2.text((w2 // 2 - 58, 88), "2 / 3", fill=(255, 255, 255, 255), font=font_big)

# 67% chip
draw2.rounded_rectangle([(w2 // 2 - 56, 162), (w2 // 2 + 56, 196)], radius=14, fill=(34, 197, 94, 38), outline=(34, 197, 94, 180), width=1)
draw2.text((w2 // 2 - 42, 169), "67% 달성", fill=(34, 197, 94, 255), font=font_small)

# Bottom Quick Check Tile
draw2.rounded_rectangle([(24, 240), (w2 - 24, 318)], radius=18, fill=(32, 35, 44, 255), outline=(50, 54, 66, 255), width=1)
draw2.text((40, 254), "1순위 빠른 체크", fill=(156, 163, 175, 255), font=font_small)
draw2.text((40, 278), "하루 30분 유산소 운동", fill=(243, 244, 246, 255), font=font_semi)
# Circle check button
draw2.ellipse([(w2 - 70, 260), (w2 - 38, 292)], fill=(40, 44, 56, 255), outline=(167, 139, 250, 255), width=2)
draw2.text((w2 - 59, 265), "○", fill=(167, 139, 250, 255), font=font_small)

img2.save(os.path.join(out_dir, "widget_preview_2x2.png"), "PNG")
print("Saved widget_preview_2x2.png")
