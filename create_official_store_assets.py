import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

build_dir = '/Users/hasangseon/three_sec_habit/build'
output_dir = '/Users/hasangseon/Desktop/three_sec_habit_playstore_assets'
os.makedirs(output_dir, exist_ok=True)

font_path = "/System/Library/Fonts/AppleSDGothicNeo.ttc"

def get_font(size, index=3): # 0: Light, 1: Medium, 2: SemiBold, 3: Bold, 4: Heavy
    try:
        return ImageFont.truetype(font_path, size, index=index)
    except:
        return ImageFont.load_default()

def draw_gradient_rect(draw, bbox, start_color, end_color):
    x0, y0, x1, y1 = bbox
    height = y1 - y0
    for y in range(height):
        ratio = y / max(1, height - 1)
        r = int(start_color[0] * (1 - ratio) + end_color[0] * ratio)
        g = int(start_color[1] * (1 - ratio) + end_color[1] * ratio)
        b = int(start_color[2] * (1 - ratio) + end_color[2] * ratio)
        draw.line([(x0, y0 + y), (x1, y0 + y)], fill=(r, g, b))

def create_store_screenshot(real_screen_filename, out_filename, badge_text, title_text, sub_text, bg_start, bg_end, glow_color):
    # Canvas: 1080 x 2400
    canvas = Image.new("RGBA", (1080, 2400), (15, 23, 42, 255))
    draw = ImageDraw.Draw(canvas)

    # Background gradient
    draw_gradient_rect(draw, (0, 0, 1080, 2400), bg_start, bg_end)

    # Soft ambient glow at top/middle
    glow = Image.new("RGBA", (1080, 2400), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse([150, 100, 930, 700], fill=(glow_color[0], glow_color[1], glow_color[2], 50))
    glow = glow.filter(ImageFilter.GaussianBlur(100))
    canvas.alpha_composite(glow)

    d = ImageDraw.Draw(canvas)

    # 1. Top Marketing Header
    # Badge Pill
    badge_w = len(badge_text) * 22 + 40
    bx = (1080 - badge_w) // 2
    d.rounded_rectangle([bx, 90, bx + badge_w, 145], radius=28, fill=(glow_color[0], glow_color[1], glow_color[2], 40), outline=(glow_color[0], glow_color[1], glow_color[2], 160), width=2)
    d.text((bx + 20, 102), badge_text, font=get_font(26, 3), fill=(255, 255, 255))

    # Main Headline (Centered)
    title_font = get_font(52, 4)
    # Calculate text bbox
    t_bbox = d.textbbox((0, 0), title_text, font=title_font)
    t_w = t_bbox[2] - t_bbox[0]
    d.text(((1080 - t_w) // 2, 175), title_text, font=title_font, fill=(255, 255, 255))

    # Subhead (Centered)
    sub_font = get_font(30, 1)
    s_bbox = d.textbbox((0, 0), sub_text, font=sub_font)
    s_w = s_bbox[2] - s_bbox[0]
    d.text(((1080 - s_w) // 2, 255), sub_text, font=sub_font, fill=(148, 163, 184))

    # 2. Embed 100% Real Flutter Screen Mockup
    real_img = Image.open(os.path.join(build_dir, real_screen_filename)).convert("RGBA")
    
    # Scale down slightly to fit inside elegant bezel
    # Device frame: 920 x 1980
    dev_w, dev_h = 920, 1980
    dev_x = (1080 - dev_w) // 2
    dev_y = 350

    # Device outer shadow
    shadow = Image.new("RGBA", (1080, 2400), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle([dev_x - 10, dev_y + 10, dev_x + dev_w + 10, dev_y + dev_h + 30], radius=56, fill=(0, 0, 0, 180))
    shadow = shadow.filter(ImageFilter.GaussianBlur(35))
    canvas.alpha_composite(shadow)

    # Device bezel
    d = ImageDraw.Draw(canvas)
    d.rounded_rectangle([dev_x, dev_y, dev_x + dev_w, dev_y + dev_h], radius=52, fill=(15, 23, 42), outline=(51, 65, 85), width=8)

    # Screen dimensions inside bezel: 888 x 1948
    screen_w = dev_w - 32
    screen_h = dev_h - 32
    screen_x = dev_x + 16
    screen_y = dev_y + 16

    # Resize real Flutter screenshot to fit screen area
    real_resized = real_img.resize((screen_w, screen_h), Image.Resampling.LANCZOS)

    # Mask with rounded corners
    screen_mask = Image.new("L", (screen_w, screen_h), 0)
    sm_draw = ImageDraw.Draw(screen_mask)
    sm_draw.rounded_rectangle([0, 0, screen_w, screen_h], radius=40, fill=255)

    canvas.paste(real_resized, (screen_x, screen_y), screen_mask)

    # Device Dynamic Island / Speaker cutout at top
    d.rounded_rectangle([dev_x + dev_w//2 - 90, dev_y + 24, dev_x + dev_w//2 + 90, dev_y + 56], radius=16, fill=(10, 15, 29))

    # Save final screenshot
    out_path = os.path.join(output_dir, out_filename)
    canvas.save(out_path, "PNG")
    print(f"Generated 100% Real UI Screenshot: {out_filename}")

# Generate 4 Real-App Screenshots
create_store_screenshot(
    real_screen_filename='real_screen_1_home.png',
    out_filename='screenshot_1_home.png',
    badge_text='⚡ 3초 컷 손맛 체크',
    title_text='원터치 3초 만에 오늘 습관 완성',
    sub_text='복잡한 과정 없이 켜자마자 바로 체크하고 성취감 UP',
    bg_start=(30, 27, 75),
    bg_end=(15, 23, 42),
    glow_color=(139, 92, 246)
)

create_store_screenshot(
    real_screen_filename='real_screen_2_water.png',
    out_filename='screenshot_2_water_count.png',
    badge_text='💧 물마시기 카운터 & 주기 알림',
    title_text='하루 8잔 물마시기 & 실시간 게이지',
    sub_text='1시간마다 스마트 알림으로 건강한 습관을 챙겨요',
    bg_start=(6, 78, 99),
    bg_end=(15, 23, 42),
    glow_color=(6, 182, 212)
)

create_store_screenshot(
    real_screen_filename='real_screen_3_stats.png',
    out_filename='screenshot_3_stats_grass.png',
    badge_text='🟩 깃허브 잔디밭 캘린더',
    title_text='초록빛으로 확인하는 나의 성취',
    sub_text='월간 잔디밭 캘린더와 연속 달성 스트릭(🔥) 통계',
    bg_start=(6, 78, 59),
    bg_end=(15, 23, 42),
    glow_color=(16, 185, 129)
)

create_store_screenshot(
    real_screen_filename='real_screen_4_edit.png',
    out_filename='screenshot_4_custom_habit.png',
    badge_text='⚙️ 나만의 맞춤 습관 & 알림',
    title_text='자유로운 반복 주기와 간격 알림',
    sub_text='단순 체크형부터 목표 횟수형, 요일별 반복까지 완벽 지원',
    bg_start=(79, 70, 229),
    bg_end=(15, 23, 42),
    glow_color=(139, 92, 246)
)

print("ALL REAL APP SCREENSHOTS GENERATED SUCCESSFULLY!")
