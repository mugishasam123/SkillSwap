#!/usr/bin/env python3
"""
Diagram Generator for SkillSwap App
Converts ASCII diagrams to PNG images using matplotlib
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, Rectangle
import numpy as np
from PIL import Image, ImageDraw, ImageFont
import os

def create_app_structure_diagram():
    """Create the main app structure diagram"""
    fig, ax = plt.subplots(1, 1, figsize=(16, 12))
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')
    
    # Title
    ax.text(50, 95, 'SkillSwap Flutter Application Structure', 
            fontsize=20, fontweight='bold', ha='center')
    
    # Main container
    main_box = FancyBboxPatch((5, 5), 90, 85, 
                             boxstyle="round,pad=0.5", 
                             facecolor='lightblue', 
                             edgecolor='navy', 
                             linewidth=2)
    ax.add_patch(main_box)
    
    # lib/ section
    lib_box = FancyBboxPatch((10, 75), 80, 10, 
                            boxstyle="round,pad=0.3", 
                            facecolor='lightgreen', 
                            edgecolor='darkgreen')
    ax.add_patch(lib_box)
    ax.text(50, 80, 'lib/', fontsize=14, fontweight='bold', ha='center')
    
    # Core section
    core_box = FancyBboxPatch((10, 60), 80, 10, 
                             boxstyle="round,pad=0.3", 
                             facecolor='lightyellow', 
                             edgecolor='orange')
    ax.add_patch(core_box)
    ax.text(50, 65, 'core/ (theme, services, widgets)', fontsize=12, ha='center')
    
    # Features sections
    features = [
        ('auth/', 50, 'lightcoral'),
        ('home/', 40, 'lightpink'),
        ('messages/', 30, 'lightcyan'),
        ('profile/', 20, 'lightgray'),
        ('swap/', 10, 'lightgreen'),
        ('forum/', 0, 'lightblue'),
        ('onboarding/', -10, 'lightyellow')
    ]
    
    for feature, y_pos, color in features:
        feature_box = FancyBboxPatch((10, y_pos), 80, 8, 
                                   boxstyle="round,pad=0.2", 
                                   facecolor=color, 
                                   edgecolor='black')
        ax.add_patch(feature_box)
        ax.text(50, y_pos + 4, feature, fontsize=10, ha='center')
    
    # Assets section
    assets_box = FancyBboxPatch((10, -20), 80, 8, 
                               boxstyle="round,pad=0.3", 
                               facecolor='lightsteelblue', 
                               edgecolor='steelblue')
    ax.add_patch(assets_box)
    ax.text(50, -16, 'assets/ (images, fonts, icons)', fontsize=12, ha='center')
    
    plt.tight_layout()
    plt.savefig('app_structure_diagram.png', dpi=300, bbox_inches='tight')
    plt.close()

def create_bloc_architecture_diagram():
    """Create the BLoC architecture diagram"""
    fig, ax = plt.subplots(1, 1, figsize=(16, 12))
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')
    
    # Title
    ax.text(50, 95, 'BLoC Pattern Architecture', 
            fontsize=20, fontweight='bold', ha='center')
    
    # UI Layer
    ui_box = FancyBboxPatch((10, 80), 80, 10, 
                           boxstyle="round,pad=0.5", 
                           facecolor='lightblue', 
                           edgecolor='navy')
    ax.add_patch(ui_box)
    ax.text(50, 85, 'UI Layer (Presentation)', fontsize=14, fontweight='bold', ha='center')
    
    # BLoC Layer
    bloc_box = FancyBboxPatch((10, 60), 80, 15, 
                             boxstyle="round,pad=0.5", 
                             facecolor='lightgreen', 
                             edgecolor='darkgreen')
    ax.add_patch(bloc_box)
    ax.text(50, 75, 'BLoC Layer (Business Logic)', fontsize=14, fontweight='bold', ha='center')
    
    # Auth BLoC
    auth_box = FancyBboxPatch((15, 62), 35, 10, 
                             boxstyle="round,pad=0.3", 
                             facecolor='lightcoral', 
                             edgecolor='red')
    ax.add_patch(auth_box)
    ax.text(32.5, 67, 'Auth BLoC', fontsize=12, fontweight='bold', ha='center')
    
    # Theme BLoC
    theme_box = FancyBboxPatch((55, 62), 35, 10, 
                              boxstyle="round,pad=0.3", 
                              facecolor='lightyellow', 
                              edgecolor='orange')
    ax.add_patch(theme_box)
    ax.text(72.5, 67, 'Theme BLoC', fontsize=12, fontweight='bold', ha='center')
    
    # Repository Layer
    repo_box = FancyBboxPatch((10, 40), 80, 15, 
                             boxstyle="round,pad=0.5", 
                             facecolor='lightyellow', 
                             edgecolor='orange')
    ax.add_patch(repo_box)
    ax.text(50, 55, 'Repository Layer (Data)', fontsize=14, fontweight='bold', ha='center')
    
    # Repositories
    repos = [
        ('Swap Repo', 20, 'lightpink'),
        ('Message Repo', 35, 'lightcyan'),
        ('Profile Repo', 50, 'lightgray'),
        ('Forum Repo', 65, 'lightsteelblue')
    ]
    
    for repo, x_pos, color in repos:
        repo_box = FancyBboxPatch((x_pos, 42), 12, 10, 
                                 boxstyle="round,pad=0.2", 
                                 facecolor=color, 
                                 edgecolor='black')
        ax.add_patch(repo_box)
        ax.text(x_pos + 6, 47, repo, fontsize=8, ha='center', wrap=True)
    
    # Firebase Layer
    firebase_box = FancyBboxPatch((10, 15), 80, 15, 
                                 boxstyle="round,pad=0.5", 
                                 facecolor='lightcoral', 
                                 edgecolor='red')
    ax.add_patch(firebase_box)
    ax.text(50, 30, 'Firebase Services', fontsize=14, fontweight='bold', ha='center')
    
    # Firebase services
    services = [
        ('Firestore', 20, 'lightblue'),
        ('Auth', 35, 'lightgreen'),
        ('Storage', 50, 'lightyellow'),
        ('Real-time', 65, 'lightpink')
    ]
    
    for service, x_pos, color in services:
        service_box = FancyBboxPatch((x_pos, 17), 12, 10, 
                                    boxstyle="round,pad=0.2", 
                                    facecolor=color, 
                                    edgecolor='black')
        ax.add_patch(service_box)
        ax.text(x_pos + 6, 22, service, fontsize=8, ha='center')
    
    # Arrows
    arrow_props = dict(arrowstyle='->', color='black', lw=2)
    ax.annotate('', xy=(50, 75), xytext=(50, 80), arrowprops=arrow_props)
    ax.annotate('', xy=(50, 55), xytext=(50, 60), arrowprops=arrow_props)
    ax.annotate('', xy=(50, 30), xytext=(50, 40), arrowprops=arrow_props)
    
    plt.tight_layout()
    plt.savefig('bloc_architecture_diagram.png', dpi=300, bbox_inches='tight')
    plt.close()

def create_data_flow_diagram():
    """Create the data flow diagram"""
    fig, ax = plt.subplots(1, 1, figsize=(16, 12))
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')
    
    # Title
    ax.text(50, 95, 'Data Flow Architecture', 
            fontsize=20, fontweight='bold', ha='center')
    
    # Flow boxes
    boxes = [
        ('User\nInteraction', 10, 70, 'lightblue'),
        ('UI\n(Widget)', 25, 70, 'lightgreen'),
        ('BLoC\n(Events)', 40, 70, 'lightyellow'),
        ('Repository\n(Data)', 55, 70, 'lightcoral'),
        ('Firebase\nServices', 70, 70, 'lightpink')
    ]
    
    # Draw boxes
    for text, x, y, color in boxes:
        box = FancyBboxPatch((x, y), 12, 15, 
                           boxstyle="round,pad=0.3", 
                           facecolor=color, 
                           edgecolor='black')
        ax.add_patch(box)
        ax.text(x + 6, y + 7.5, text, fontsize=10, ha='center', va='center')
    
    # Response boxes
    response_boxes = [
        ('State\nChanges', 10, 45, 'lightblue'),
        ('BLoC\n(States)', 25, 45, 'lightgreen'),
        ('State\nUpdates', 40, 45, 'lightyellow'),
        ('Data\nModels', 55, 45, 'lightcoral'),
        ('Response\n(JSON)', 70, 45, 'lightpink')
    ]
    
    # Draw response boxes
    for text, x, y, color in response_boxes:
        box = FancyBboxPatch((x, y), 12, 15, 
                           boxstyle="round,pad=0.3", 
                           facecolor=color, 
                           edgecolor='black')
        ax.add_patch(box)
        ax.text(x + 6, y + 7.5, text, fontsize=10, ha='center', va='center')
    
    # Arrows
    arrow_props = dict(arrowstyle='->', color='black', lw=2)
    
    # Forward flow
    for i in range(4):
        x1 = 22 + i * 15
        x2 = 28 + i * 15
        ax.annotate('', xy=(x2, 77.5), xytext=(x1, 77.5), arrowprops=arrow_props)
    
    # Response flow
    for i in range(4):
        x1 = 28 + i * 15
        x2 = 22 + i * 15
        ax.annotate('', xy=(x2, 52.5), xytext=(x1, 52.5), arrowprops=arrow_props)
    
    # Vertical connections
    for i in range(5):
        x = 16 + i * 15
        ax.annotate('', xy=(x, 60), xytext=(x, 45), arrowprops=arrow_props)
    
    plt.tight_layout()
    plt.savefig('data_flow_diagram.png', dpi=300, bbox_inches='tight')
    plt.close()

def create_login_flow_diagram():
    """Create the login flow diagram"""
    fig, ax = plt.subplots(1, 1, figsize=(16, 12))
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')
    
    # Title
    ax.text(50, 95, 'User Login Flow', 
            fontsize=20, fontweight='bold', ha='center')
    
    # Flow steps
    steps = [
        ('User taps\nLogin Button', 10, 80, 'lightblue'),
        ('LoginPage\nWidget', 25, 80, 'lightgreen'),
        ('AuthBloc\nEvent', 40, 80, 'lightyellow'),
        ('AuthRepo\nLogin()', 55, 80, 'lightcoral'),
        ('Firebase\nAuth', 70, 80, 'lightpink')
    ]
    
    # Draw steps
    for text, x, y, color in steps:
        box = FancyBboxPatch((x, y), 12, 15, 
                           boxstyle="round,pad=0.3", 
                           facecolor=color, 
                           edgecolor='black')
        ax.add_patch(box)
        ax.text(x + 6, y + 7.5, text, fontsize=9, ha='center', va='center')
    
    # Response steps
    response_steps = [
        ('UI Updates\n(Loading)', 10, 55, 'lightblue'),
        ('AuthState\n(Success)', 25, 55, 'lightgreen'),
        ('AuthSuccess\nState', 40, 55, 'lightyellow'),
        ('User Data\n(User Model)', 55, 55, 'lightcoral'),
        ('Auth Token\n(Firebase)', 70, 55, 'lightpink')
    ]
    
    # Draw response steps
    for text, x, y, color in response_steps:
        box = FancyBboxPatch((x, y), 12, 15, 
                           boxstyle="round,pad=0.3", 
                           facecolor=color, 
                           edgecolor='black')
        ax.add_patch(box)
        ax.text(x + 6, y + 7.5, text, fontsize=9, ha='center', va='center')
    
    # Arrows
    arrow_props = dict(arrowstyle='->', color='black', lw=2)
    
    # Forward flow
    for i in range(4):
        x1 = 22 + i * 15
        x2 = 28 + i * 15
        ax.annotate('', xy=(x2, 87.5), xytext=(x1, 87.5), arrowprops=arrow_props)
    
    # Response flow
    for i in range(4):
        x1 = 28 + i * 15
        x2 = 22 + i * 15
        ax.annotate('', xy=(x2, 62.5), xytext=(x1, 62.5), arrowprops=arrow_props)
    
    # Vertical connections
    for i in range(5):
        x = 16 + i * 15
        ax.annotate('', xy=(x, 70), xytext=(x, 55), arrowprops=arrow_props)
    
    plt.tight_layout()
    plt.savefig('login_flow_diagram.png', dpi=300, bbox_inches='tight')
    plt.close()

def main():
    """Generate all diagrams"""
    print("Generating SkillSwap app diagrams...")
    
    # Create output directory if it doesn't exist
    os.makedirs('diagrams', exist_ok=True)
    
    # Generate each diagram
    create_app_structure_diagram()
    print("✓ App structure diagram created")
    
    create_bloc_architecture_diagram()
    print("✓ BLoC architecture diagram created")
    
    create_data_flow_diagram()
    print("✓ Data flow diagram created")
    
    create_login_flow_diagram()
    print("✓ Login flow diagram created")
    
    print("\nAll diagrams have been generated successfully!")
    print("Files created:")
    print("- app_structure_diagram.png")
    print("- bloc_architecture_diagram.png")
    print("- data_flow_diagram.png")
    print("- login_flow_diagram.png")

if __name__ == "__main__":
    main() 