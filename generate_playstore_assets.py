import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

output_dir = "/Users/hasangseon/Desktop/three_sec_habit_playstore_assets"
os.makedirs(output_dir, exist_ok=True)

# Load fonts
font_path = "/System/Library/Fonts/AppleSDGothicNeo.ttc"

def get_font(size, index=0): # 0: Light, 1: Medium, 2: SemiBold, 3: Bold, 4: Heavy
    try:
        return ImageFont.truetype(font_path, size, index=index)
    except:
        return ImageFont.load_default()

def draw_gradient_rect(draw, bbox, start_color, end_color, vertical=True):
    x0, y0, x1, y1 = bbox
    width = x1 - x0
    height = y1 - y0
    if vertical:
        for y in range(height):
            ratio = y / max(1, height - 1)
            r = int(start_color[0] * (1 - ratio) + end_color[0] * ratio)
            g = int(start_color[1] * (1 - ratio) + end_color[1] * ratio)
            b = int(start_color[2] * (1 - ratio) + end_color[2] * ratio)
            draw.line([(x0, y0 + y), (x1, y0 + y)], fill=(r, g, b))
    else:
        for x in range(width):
            ratio = x / max(1, width - 1)
            r = int(start_color[0] * (1 - ratio) + end_color[0] * ratio)
            g = int(start_color[1] * (1 - ratio) + end_color[1] * ratio)
            b = int(start_color[2] * (1 - ratio) + end_color[2] * ratio)
            draw.line([(x0 + x, y0), (x0 + x, y1)], fill=(r, g, b))

# ----------------------------------------------------
# 1. App Icon (512 x 512)
# ----------------------------------------------------
def create_app_icon():
    img = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Rounded background with vibrant purple/indigo gradient
    bg = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
    bg_draw = ImageDraw.Draw(bg)
    draw_gradient_rect(bg_draw, (0, 0, 512, 512), (129, 90, 246), (79, 70, 229), vertical=True)
    
    # Mask rounded rectangle
    mask = Image.new("L", (512, 512), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, 512, 512], radius=115, fill=255)
    img.paste(bg, (0, 0), mask)

    # Glow effect
    glow = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    glow_draw.ellipse([100, 100, 412, 412], fill=(255, 255, 255, 45))
    glow = glow.filter(ImageFilter.GaussianBlur(50))
    img.alpha_composite(glow)

    # Icon: Lightning bolt + checkmark / water drop symbol
    d = ImageDraw.Draw(img)
    
    # Lightning bolt polygon (gold / bright yellow gradient)
    bolt_points = [
        (290, 80),
        (170, 260),
        (260, 260),
        (220, 430),
        (350, 220),
        (270, 220),
        (320, 80)
    ]
    # Shadow for bolt
    shadow_bolt = [(x + 4, y + 6) for (x, y) in bolt_points]
    d.polygon(shadow_bolt, fill=(30, 27, 75, 120))
    d.polygon(bolt_points, fill=(255, 214, 10))

    # Inner highlight on bolt
    highlight_points = [
        (280, 100),
        (190, 245),
        (260, 245),
        (240, 360),
        (330, 230),
        (270, 230),
        (305, 100)
    ]
    d.polygon(highlight_points, fill=(255, 235, 100, 180))

    # Bold Check Badge at bottom right
    d.ellipse([270, 270, 430, 430], fill=(16, 185, 129))
    d.ellipse([270, 270, 430, 430], outline=(255, 255, 255), width=10)
    
    # Checkmark lines
    check_pts = [(315, 350), (345, 380), (395, 320)]
    d.line([check_pts[0], check_pts[1]], fill=(255, 255, 255), width=16)
    d.line([check_pts[1], check_pts[2]], fill=(255, 255, 255), width=16)
    d.ellipse([check_pts[0][0]-8, check_pts[0][1]-8, check_pts[0][0]+8, check_pts[0][1]+8], fill=(255, 255, 255))
    d.ellipse([check_pts[1][0]-8, check_pts[1][1]-8, check_pts[1][0]+8, check_pts[1][1]+8], fill=(255, 255, 255))
    d.ellipse([check_pts[2][0]-8, check_pts[2][1]-8, check_pts[2][0]+8, check_pts[2][1]+8], fill=(255, 255, 255))

    img.save(os.path.join(output_dir, "app_icon.png"), "PNG")
    print("Created app_icon.png (512x512)")

# ----------------------------------------------------
# 2. Feature Graphic (1024 x 500)
# ----------------------------------------------------
def create_feature_graphic():
    img = Image.new("RGBA", (1024, 500), (15, 23, 42, 255))
    draw = ImageDraw.Draw(img)

    # Background gradient
    draw_gradient_rect(draw, (0, 0, 1024, 500), (15, 23, 42), (30, 27, 75), vertical=False)

    # Ambient glow lights
    glow = Image.new("RGBA", (1024, 500), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse([50, 100, 450, 500], fill=(139, 92, 246, 40))
    gd.ellipse([650, 50, 1050, 450], fill=(16, 185, 129, 35))
    glow = glow.filter(ImageFilter.GaussianBlur(80))
    img.alpha_composite(glow)

    d = ImageDraw.Draw(img)

    # Left content: Typography
    # Badge
    d.rounded_rectangle([70, 65, 270, 105], radius=20, fill=(139, 92, 246, 60), outline=(139, 92, 246, 150), width=1)
    d.text((85, 75), "⚡ 3초 컷 초간편 루틴", font=get_font(20, 3), fill=(196, 181, 253))

    # Main Title
    d.text((70, 120), "3초 습관", font=get_font(56, 4), fill=(255, 255, 255))
    
    # Subtitle
    d.text((70, 195), "앱 켜고 3초 만에 원터치 완료!", font=get_font(24, 2), fill=(226, 232, 240))
    d.text((70, 230), "하루 8잔 물마시기부터 깃허브 잔디밭까지", font=get_font(18, 1), fill=(148, 163, 184))

    # Feature tags (Pills)
    features = [
        ("✓ 원터치 빠른 체크", (16, 185, 129)),
        ("✓ 물마시기 8잔 카운터", (6, 182, 212)),
        ("✓ 1~2시간 주기 스마트 알림", (245, 158, 11)),
        ("✓ 깃허브 잔디밭 캘린더", (139, 92, 246)),
    ]
    cur_y = 285
    for text, color in features[:2]:
        d.rounded_rectangle([70, cur_y, 290, cur_y + 40], radius=12, fill=(30, 41, 59, 200), outline=color, width=1)
        d.text((85, cur_y + 10), text, font=get_font(15, 2), fill=(248, 250, 252))
        cur_y += 50
    
    cur_y = 285
    for text, color in features[2:]:
        d.rounded_rectangle([305, cur_y, 545, cur_y + 40], radius=12, fill=(30, 41, 59, 200), outline=color, width=1)
        d.text((320, cur_y + 10), text, font=get_font(15, 2), fill=(248, 250, 252))
        cur_y += 50

    # Right side: App UI Cards preview (Mockups)
    # Card 1: Main Habit Card
    cx, cy = 600, 70
    d.rounded_rectangle([cx, cy, cx + 360, cy + 105], radius=22, fill=(30, 41, 59, 240), outline=(51, 65, 85, 255), width=2)
    # Icon box
    d.rounded_rectangle([cx + 16, cy + 18, cx + 80, cy + 82], radius=16, fill=(139, 92, 246, 60))
    d.text((cx + 34, cy + 28), "💧", font=get_font(30, 1))
    d.text((cx + 96, cy + 25), "물 8잔 마시기", font=get_font(20, 3), fill=(255, 255, 255))
    d.text((cx + 96, cy + 55), "1시간마다 알림 • 5 / 8 잔", font=get_font(14, 1), fill=(148, 163, 184))
    # Progress Bar
    d.rounded_rectangle([cx + 96, cy + 78, cx + 270, cy + 86], radius=4, fill=(51, 65, 85))
    d.rounded_rectangle([cx + 96, cy + 78, cx + 205, cy + 86], radius=4, fill=(6, 182, 212))
    # Check button
    d.ellipse([cx + 295, cy + 30, cx + 345, cy + 80], fill=(6, 182, 212))
    d.text((cx + 307, cy + 42), "5", font=get_font(20, 4), fill=(255, 255, 255))

    # Card 2: Completed Habit Card
    cy2 = cy + 125
    d.rounded_rectangle([cx, cy2, cx + 360, cy2 + 105], radius=22, fill=(30, 41, 59, 240), outline=(16, 185, 129, 120), width=2)
    d.rounded_rectangle([cx + 16, cy2 + 18, cx + 80, cy2 + 82], radius=16, fill=(16, 185, 129, 50))
    d.text((cx + 34, cy2 + 28), "🏃", font=get_font(30, 1))
    d.text((cx + 96, cy2 + 25), "아침 20분 러닝", font=get_font(20, 3), fill=(148, 163, 184))
    d.text((cx + 96, cy2 + 55), "매일 실천 • 🔥 7일 연속", font=get_font(14, 2), fill=(245, 158, 11))
    # Check done circle
    d.ellipse([cx + 295, cy2 + 30, cx + 345, cy2 + 80], fill=(16, 185, 129))
    d.text((cx + 310, cy2 + 40), "✓", font=get_font(26, 4), fill=(255, 255, 255))

    # Card 3: Mini Streak Banner
    cy3 = cy2 + 125
    d.rounded_rectangle([cx, cy3, cx + 360, cy3 + 90], radius=22, fill=(139, 92, 246, 50), outline=(139, 92, 246, 150), width=2)
    d.text((cx + 20, cy3 + 20), "🔥 현재 연속 14일 달성 중!", font=get_font(18, 3), fill=(255, 255, 255))
    d.text((cx + 20, cy3 + 50), "오늘 완료율 100% 달성 완료 🎉", font=get_font(14, 1), fill=(196, 181, 253))

    img.save(os.path.join(output_dir, "feature_graphic.png"), "PNG")
    print("Created feature_graphic.png (1024x500)")

# ----------------------------------------------------
# 3. Phone Screenshots (1080 x 2400 each)
# ----------------------------------------------------
def draw_phone_frame(draw, x0, y0, width, height):
    # Outer device bezel
    draw.rounded_rectangle([x0, y0, x0 + width, y0 + height], radius=60, fill=(15, 23, 42), outline=(51, 65, 85), width=8)
    # Inner screen
    draw.rounded_rectangle([x0 + 16, y0 + 16, x0 + width - 16, y0 + height - 16], radius=48, fill=(10, 15, 29))
    # Dynamic Island / Camera cutout
    draw.rounded_rectangle([x0 + width//2 - 90, y0 + 35, x0 + width//2 + 90, y0 + 75], radius=20, fill=(2, 6, 23))

def create_screenshot_1():
    img = Image.new("RGBA", (1080, 2400), (15, 23, 42, 255))
    draw = ImageDraw.Draw(img)
    draw_gradient_rect(draw, (0, 0, 1080, 2400), (30, 27, 75), (15, 23, 42), vertical=True)

    # Top Header
    draw.rounded_rectangle([390, 120, 690, 180], radius=30, fill=(139, 92, 246, 50), outline=(139, 92, 246, 150), width=2)
    draw.text((420, 135), "⚡ 3초 컷 손맛 체크", font=get_font(32, 3), fill=(196, 181, 253))
    
    draw.text((120, 230), "앱 켜고 3초 만에 완료!", font=get_font(68, 4), fill=(255, 255, 255))
    draw.text((120, 330), "복잡한 과정 없이 원터치로 오늘 습관을 완성하세요", font=get_font(36, 1), fill=(148, 163, 184))

    # Phone Frame
    px, py, pw, ph = 80, 480, 920, 1850
    draw_phone_frame(draw, px, py, pw, ph)
    
    # Inside Screen contents
    sx = px + 40
    sy = py + 120

    # App Bar
    draw.text((sx + 30, sy), "⚡ 3초 습관", font=get_font(44, 4), fill=(255, 255, 255))
    draw.text((sx + 680, sy + 5), "📅", font=get_font(36, 1))

    # Today Progress Card
    ty = sy + 90
    draw.rounded_rectangle([sx + 10, ty, sx + 830, ty + 240], radius=36, fill=(30, 41, 59, 230), outline=(51, 65, 85), width=2)
    draw.text((sx + 45, ty + 35), "8월 30일 (일)", font=get_font(28, 2), fill=(148, 163, 184))
    draw.text((sx + 45, ty + 80), "오늘 목표 75% 달성!", font=get_font(42, 4), fill=(255, 255, 255))
    draw.text((sx + 45, ty + 140), "3개 완료됨 (1개 남음)", font=get_font(26, 1), fill=(16, 185, 129))
    
    # Progress Bar
    draw.rounded_rectangle([sx + 45, ty + 190, sx + 795, ty + 208], radius=9, fill=(51, 65, 85))
    draw.rounded_rectangle([sx + 45, ty + 190, sx + 607, ty + 208], radius=9, fill=(16, 185, 129))

    # Habit Item 1: Done
    hy1 = ty + 280
    draw.rounded_rectangle([sx + 10, hy1, sx + 830, hy1 + 170], radius=32, fill=(30, 41, 59, 200), outline=(16, 185, 129, 100), width=2)
    draw.rounded_rectangle([sx + 35, hy1 + 25, sx + 155, hy1 + 145], radius=24, fill=(6, 182, 212, 40))
    draw.text((sx + 65, hy1 + 45), "💧", font=get_font(50, 1))
    draw.text((sx + 180, hy1 + 35), "기상 직후 물 한 잔", font=get_font(34, 3), fill=(148, 163, 184))
    draw.text((sx + 180, hy1 + 95), "매일 • 🔥 7일 연속 달성", font=get_font(24, 2), fill=(245, 158, 11))
    # Done Check Button
    draw.ellipse([sx + 700, hy1 + 45, sx + 785, hy1 + 130], fill=(16, 185, 129))
    draw.text((sx + 725, hy1 + 60), "✓", font=get_font(42, 4), fill=(255, 255, 255))

    # Habit Item 2: Done
    hy2 = hy1 + 200
    draw.rounded_rectangle([sx + 10, hy2, sx + 830, hy2 + 170], radius=32, fill=(30, 41, 59, 200), outline=(16, 185, 129, 100), width=2)
    draw.rounded_rectangle([sx + 35, hy2 + 25, sx + 155, hy2 + 145], radius=24, fill=(139, 92, 246, 40))
    draw.text((sx + 65, hy2 + 45), "🏃", font=get_font(50, 1))
    draw.text((sx + 180, hy2 + 35), "아침 20분 러닝", font=get_font(34, 3), fill=(148, 163, 184))
    draw.text((sx + 180, hy2 + 95), "매일 • 🔥 5일 연속 달성", font=get_font(24, 2), fill=(245, 158, 11))
    draw.ellipse([sx + 700, hy2 + 45, sx + 785, hy2 + 130], fill=(16, 185, 129))
    draw.text((sx + 725, hy2 + 60), "✓", font=get_font(42, 4), fill=(255, 255, 255))

    # Habit Item 3: Undone
    hy3 = hy2 + 200
    draw.rounded_rectangle([sx + 10, hy3, sx + 830, hy3 + 170], radius=32, fill=(30, 41, 59, 240), outline=(51, 65, 85), width=2)
    draw.rounded_rectangle([sx + 35, hy3 + 25, sx + 155, hy3 + 145], radius=24, fill=(245, 158, 11, 40))
    draw.text((sx + 65, hy3 + 45), "📚", font=get_font(50, 1))
    draw.text((sx + 180, hy3 + 35), "10분 독서하기", font=get_font(34, 3), fill=(255, 255, 255))
    draw.text((sx + 180, hy3 + 95), "주 3회 • 🔥 3일 연속 달성", font=get_font(24, 2), fill=(245, 158, 11))
    draw.ellipse([sx + 700, hy3 + 45, sx + 785, hy3 + 130], fill=(15, 23, 42), outline=(51, 65, 85), width=3)

    img.save(os.path.join(output_dir, "screenshot_1_home.png"), "PNG")
    print("Created screenshot_1_home.png (1080x2400)")

def create_screenshot_2():
    img = Image.new("RGBA", (1080, 2400), (15, 23, 42, 255))
    draw = ImageDraw.Draw(img)
    draw_gradient_rect(draw, (0, 0, 1080, 2400), (6, 78, 99), (15, 23, 42), vertical=True)

    # Top Header
    draw.rounded_rectangle([330, 120, 750, 180], radius=30, fill=(6, 182, 212, 50), outline=(6, 182, 212, 150), width=2)
    draw.text((360, 135), "💧 물마시기 & 주기 알림", font=get_font(32, 3), fill=(165, 243, 252))
    
    draw.text((120, 230), "하루 8잔 목표 실시간 카운트", font=get_font(64, 4), fill=(255, 255, 255))
    draw.text((120, 330), "1~2시간마다 스마트 알림으로 잊지 않고 챙겨요", font=get_font(36, 1), fill=(148, 163, 184))

    # Phone Frame
    px, py, pw, ph = 80, 480, 920, 1850
    draw_phone_frame(draw, px, py, pw, ph)
    
    sx = px + 40
    sy = py + 120

    # Notification Banner floating at top
    ny = sy + 30
    draw.rounded_rectangle([sx + 10, ny, sx + 830, ny + 170], radius=32, fill=(30, 41, 59, 250), outline=(6, 182, 212, 180), width=2)
    draw.text((sx + 40, ny + 30), "🔔 3초 습관 • 방금 전", font=get_font(24, 2), fill=(6, 182, 212))
    draw.text((sx + 40, ny + 70), "💧 [물 8잔 마시기] 실천할 시간이에요!", font=get_font(30, 3), fill=(255, 255, 255))
    draw.text((sx + 40, ny + 115), "오늘의 목표(8잔)를 향해 1잔 더 마셔보세요.", font=get_font(22, 1), fill=(148, 163, 184))

    # Habit Card 1: Count Habit (Water 8 Cups)
    cy1 = ny + 230
    draw.rounded_rectangle([sx + 10, cy1, sx + 830, cy1 + 250], radius=36, fill=(30, 41, 59, 240), outline=(6, 182, 212, 120), width=2)
    draw.rounded_rectangle([sx + 35, cy1 + 30, sx + 155, cy1 + 150], radius=24, fill=(6, 182, 212, 40))
    draw.text((sx + 65, cy1 + 50), "💧", font=get_font(50, 1))
    draw.text((sx + 180, cy1 + 40), "물 8잔 마시기", font=get_font(36, 3), fill=(255, 255, 255))
    draw.text((sx + 180, cy1 + 95), "매일 • 1시간마다 알림 • 🔥 8일 연속", font=get_font(24, 2), fill=(6, 182, 212))
    
    # Decrement (-) & Increment (+) Steppers
    draw.ellipse([sx + 580, cy1 + 45, sx + 665, cy1 + 130], fill=(15, 23, 42), outline=(51, 65, 85), width=2)
    draw.text((sx + 610, cy1 + 60), "-", font=get_font(46, 3), fill=(148, 163, 184))

    draw.ellipse([sx + 700, cy1 + 45, sx + 785, cy1 + 130], fill=(6, 182, 212))
    draw.text((sx + 730, cy1 + 55), "5", font=get_font(36, 4), fill=(255, 255, 255))
    draw.text((sx + 725, cy1 + 95), "+1", font=get_font(18, 3), fill=(207, 250, 254))

    # Progress bar and text
    draw.rounded_rectangle([sx + 45, cy1 + 190, sx + 630, cy1 + 208], radius=9, fill=(51, 65, 85))
    draw.rounded_rectangle([sx + 45, cy1 + 190, sx + 410, cy1 + 208], radius=9, fill=(6, 182, 212))
    draw.text((sx + 655, cy1 + 185), "5 / 8 잔 (62%)", font=get_font(24, 3), fill=(6, 182, 212))

    # Habit Card 2: Stretching count
    cy2 = cy1 + 290
    draw.rounded_rectangle([sx + 10, cy2, sx + 830, cy2 + 250], radius=36, fill=(30, 41, 59, 240), outline=(139, 92, 246, 120), width=2)
    draw.rounded_rectangle([sx + 35, cy2 + 30, sx + 155, cy2 + 150], radius=24, fill=(139, 92, 246, 40))
    draw.text((sx + 65, cy2 + 50), "🤸", font=get_font(50, 1))
    draw.text((sx + 180, cy2 + 40), "목/허리 스트레칭", font=get_font(36, 3), fill=(255, 255, 255))
    draw.text((sx + 180, cy2 + 95), "매일 • 2시간마다 알림", font=get_font(24, 2), fill=(196, 181, 253))
    
    draw.ellipse([sx + 580, cy2 + 45, sx + 665, cy2 + 130], fill=(15, 23, 42), outline=(51, 65, 85), width=2)
    draw.text((sx + 610, cy2 + 60), "-", font=get_font(46, 3), fill=(148, 163, 184))

    draw.ellipse([sx + 700, cy2 + 45, sx + 785, cy2 + 130], fill=(139, 92, 246))
    draw.text((sx + 730, cy2 + 55), "3", font=get_font(36, 4), fill=(255, 255, 255))
    draw.text((sx + 725, cy2 + 95), "+1", font=get_font(18, 3), fill=(237, 233, 254))

    draw.rounded_rectangle([sx + 45, cy2 + 190, sx + 630, cy2 + 208], radius=9, fill=(51, 65, 85))
    draw.rounded_rectangle([sx + 45, cy2 + 190, sx + 337, cy2 + 208], radius=9, fill=(139, 92, 246))
    draw.text((sx + 655, cy2 + 185), "3 / 6 회 (50%)", font=get_font(24, 3), fill=(139, 92, 246))

    img.save(os.path.join(output_dir, "screenshot_2_water_count.png"), "PNG")
    print("Created screenshot_2_water_count.png (1080x2400)")

def create_screenshot_3():
    img = Image.new("RGBA", (1080, 2400), (15, 23, 42, 255))
    draw = ImageDraw.Draw(img)
    draw_gradient_rect(draw, (0, 0, 1080, 2400), (6, 78, 59), (15, 23, 42), vertical=True)

    # Top Header
    draw.rounded_rectangle([320, 120, 760, 180], radius=30, fill=(16, 185, 129, 50), outline=(16, 185, 129, 150), width=2)
    draw.text((350, 135), "🟩 깃허브 잔디밭 캘린더", font=get_font(32, 3), fill=(167, 243, 208))
    
    draw.text((120, 230), "초록빛으로 물드는 나의 성취", font=get_font(64, 4), fill=(255, 255, 255))
    draw.text((120, 330), "연속 달성 스트릭과 월간 통계를 한눈에 확인해요", font=get_font(36, 1), fill=(148, 163, 184))

    # Phone Frame
    px, py, pw, ph = 80, 480, 920, 1850
    draw_phone_frame(draw, px, py, pw, ph)
    
    sx = px + 40
    sy = py + 120

    # Overall Streak Banner
    oy = sy + 30
    draw.rounded_rectangle([sx + 10, oy, sx + 830, oy + 260], radius=36, fill=(139, 92, 246, 40), outline=(139, 92, 246, 140), width=2)
    draw.text((sx + 45, oy + 40), "🔥 현재 연속 14일 달성 중!", font=get_font(38, 4), fill=(255, 255, 255))
    draw.text((sx + 45, oy + 100), "작은 습관이 모여 위대한 변화를 만듭니다.", font=get_font(24, 1), fill=(196, 181, 253))
    
    draw.text((sx + 45, oy + 175), "최장 연속 28일", font=get_font(26, 3), fill=(245, 158, 11))
    draw.text((sx + 450, oy + 175), "누적 완료 142회", font=get_font(26, 3), fill=(16, 185, 129))

    # Monthly Grass Heatmap Calendar
    my = oy + 300
    draw.rounded_rectangle([sx + 10, my, sx + 830, my + 540], radius=36, fill=(30, 41, 59, 240), outline=(51, 65, 85), width=2)
    draw.text((sx + 45, my + 35), "월간 잔디밭 (2026년 8월)", font=get_font(32, 3), fill=(255, 255, 255))
    draw.text((sx + 640, my + 40), "총 24일 성공", font=get_font(24, 2), fill=(16, 185, 129))

    # Grid of Heatmap squares (5 weeks x 7 days)
    gx0 = sx + 45
    gy0 = my + 110
    colors_level = [
        (51, 65, 85),        # 0: empty
        (6, 95, 70),         # 1: 1
        (16, 185, 129),      # 2: 2
        (52, 211, 153),      # 3: 3
        (110, 231, 183),     # 4: 4+
    ]
    
    levels = [
        [0, 1, 2, 2, 3, 4, 3],
        [2, 3, 4, 4, 3, 2, 3],
        [3, 4, 4, 4, 4, 3, 4],
        [4, 4, 3, 4, 4, 4, 3],
        [4, 4, 4, 0, 0, 0, 0]
    ]

    for row in range(5):
        for col in range(7):
            bx = gx0 + col * 110
            by = gy0 + row * 80
            lvl = levels[row][col]
            draw.rounded_rectangle([bx, by, bx + 95, by + 65], radius=14, fill=colors_level[lvl])

    # Habit Stat Cards
    hy1 = my + 580
    draw.rounded_rectangle([sx + 10, hy1, sx + 830, hy1 + 160], radius=32, fill=(30, 41, 59, 200), outline=(51, 65, 85), width=2)
    draw.text((sx + 40, hy1 + 35), "💧 물 8잔 마시기", font=get_font(32, 3), fill=(255, 255, 255))
    draw.text((sx + 40, hy1 + 90), "달성률 92% • 14일 연속 달성", font=get_font(24, 2), fill=(6, 182, 212))
    draw.text((sx + 680, hy1 + 55), "92%", font=get_font(40, 4), fill=(16, 185, 129))

    img.save(os.path.join(output_dir, "screenshot_3_stats_grass.png"), "PNG")
    print("Created screenshot_3_stats_grass.png (1080x2400)")

def create_screenshot_4():
    img = Image.new("RGBA", (1080, 2400), (15, 23, 42, 255))
    draw = ImageDraw.Draw(img)
    draw_gradient_rect(draw, (0, 0, 1080, 2400), (79, 70, 229), (15, 23, 42), vertical=True)

    # Top Header
    draw.rounded_rectangle([320, 120, 760, 180], radius=30, fill=(139, 92, 246, 50), outline=(139, 92, 246, 150), width=2)
    draw.text((350, 135), "⚙️ 나만의 맞춤 습관 & 알림", font=get_font(32, 3), fill=(196, 181, 253))
    
    draw.text((120, 230), "자유로운 반복 주기와 알림", font=get_font(64, 4), fill=(255, 255, 255))
    draw.text((120, 330), "단순 체크부터 요일별 반복, 주기적 간격 알림까지", font=get_font(36, 1), fill=(148, 163, 184))

    # Phone Frame
    px, py, pw, ph = 80, 480, 920, 1850
    draw_phone_frame(draw, px, py, pw, ph)
    
    sx = px + 40
    sy = py + 120

    # Habit Edit Form
    draw.text((sx + 30, sy), "새 습관 만들기", font=get_font(42, 4), fill=(255, 255, 255))

    # Section 1: Type Segment
    ey1 = sy + 80
    draw.text((sx + 20, ey1), "습관 기록 방식", font=get_font(26, 2), fill=(148, 163, 184))
    draw.rounded_rectangle([sx + 10, ey1 + 45, sx + 830, ey1 + 140], radius=24, fill=(30, 41, 59), outline=(51, 65, 85), width=2)
    draw.rounded_rectangle([sx + 420, ey1 + 50, sx + 825, ey1 + 135], radius=20, fill=(139, 92, 246, 80), outline=(139, 92, 246), width=2)
    draw.text((sx + 80, ey1 + 75), "단순 체크형 (1회)", font=get_font(26, 2), fill=(148, 163, 184))
    draw.text((sx + 470, ey1 + 75), "목표 횟수형 (하루 N회)", font=get_font(26, 3), fill=(255, 255, 255))

    # Section 2: Title Input
    ey2 = ey1 + 180
    draw.text((sx + 20, ey2), "습관 이름", font=get_font(26, 2), fill=(148, 163, 184))
    draw.rounded_rectangle([sx + 10, ey2 + 45, sx + 830, ey2 + 150], radius=24, fill=(30, 41, 59), outline=(139, 92, 246), width=2)
    draw.text((sx + 40, ey2 + 80), "물 8잔 마시기 💧", font=get_font(32, 3), fill=(255, 255, 255))

    # Section 3: Target Count
    ey3 = ey2 + 190
    draw.text((sx + 20, ey3), "하루 목표치 및 단위", font=get_font(26, 2), fill=(148, 163, 184))
    draw.rounded_rectangle([sx + 10, ey3 + 45, sx + 830, ey3 + 190], radius=24, fill=(30, 41, 59), outline=(51, 65, 85), width=2)
    draw.text((sx + 40, ey3 + 85), "하루 목표: 8 잔", font=get_font(30, 3), fill=(255, 255, 255))
    # Unit chips
    units = ["잔", "회", "세트", "분", "km"]
    ux = sx + 40
    for u in units:
        is_sel = (u == "잔")
        bg_col = (139, 92, 246) if is_sel else (15, 23, 42)
        draw.rounded_rectangle([ux, ey3 + 130, ux + 80, ey3 + 175], radius=14, fill=bg_col)
        draw.text((ux + 25, ey3 + 140), u, font=get_font(22, 3 if is_sel else 1), fill=(255, 255, 255))
        ux += 100

    # Section 4: Notification Settings
    ey4 = ey3 + 230
    draw.text((sx + 20, ey4), "알림 설정", font=get_font(26, 2), fill=(148, 163, 184))
    draw.rounded_rectangle([sx + 10, ey4 + 45, sx + 830, ey4 + 310], radius=28, fill=(30, 41, 59), outline=(51, 65, 85), width=2)
    draw.text((sx + 40, ey4 + 80), "🔔 반복 간격 알림 받기", font=get_font(30, 3), fill=(255, 255, 255))
    draw.text((sx + 40, ey4 + 135), "시간대: 09:00 ~ 21:00", font=get_font(26, 2), fill=(6, 182, 212))
    
    # Intervals
    intervals = ["30분마다", "1시간마다", "2시간마다", "3시간마다"]
    ix = sx + 40
    for iv in intervals:
        is_sel = (iv == "1시간마다")
        bg_col = (6, 182, 212) if is_sel else (15, 23, 42)
        draw.rounded_rectangle([ix, ey4 + 190, ix + 170, ey4 + 250], radius=16, fill=bg_col)
        draw.text((ix + 25, ey4 + 205), iv, font=get_font(24, 3 if is_sel else 1), fill=(255, 255, 255) if is_sel else (148, 163, 184))
        ix += 190

    # Bottom Save Button
    by = ey4 + 350
    draw.rounded_rectangle([sx + 10, by, sx + 830, by + 120], radius=28, fill=(139, 92, 246))
    draw.text((sx + 310, by + 35), "습관 시작하기", font=get_font(34, 4), fill=(255, 255, 255))

    img.save(os.path.join(output_dir, "screenshot_4_custom_habit.png"), "PNG")
    print("Created screenshot_4_custom_habit.png (1080x2400)")

create_app_icon()
create_feature_graphic()
create_screenshot_1()
create_screenshot_2()
create_screenshot_3()
create_screenshot_4()
print("ALL ASSETS CREATED SUCCESSFULLY AT:", output_dir)
