import 'package:flutter/material.dart';

import '../models/badge.dart';
import '../models/mission.dart';

class DummyData {
  static final tracks = <String>[
    'Design',
    'AI',
    'Marketing',
    'Coding',
    'Business',
  ];

  static final skillPool = <String>[
    'Figma',
    'Canva',
    'Prompting',
    'User Research',
    'Copywriting',
    'Social Media',
    'Python',
    'No-code',
    'Pitching',
    'Market Sizing',
  ];

  static final missions = <Mission>[
    const Mission(
      id: 'm1',
      title: 'Redesign the onboarding walkthrough',
      startupName: 'BrightSeed Labs',
      timeEstimate: '6-8 hrs',
      reward: '\$120 stipend',
      tags: ['Design', 'Figma', 'UX Writing'],
      safeForTeens: true,
      summary:
          'Create a concise 3-step walkthrough for new users showcasing the product value. Use playful illustrations and accessible copy.',
      deliverables: [
        'Figma prototype with 3 screens',
        'Copy doc with 2 headline options',
        'Accessibility checklist (contrast + tap targets)',
      ],
      safetyNotes: [
        'No sensitive data; use placeholder emails.',
        'Daily check-ins via shared doc comments only.',
      ],
      xp: 120,
    ),
    const Mission(
      id: 'm2',
      title: 'AI research brief: competitor scan',
      startupName: 'Nova AI',
      timeEstimate: '4-5 hrs',
      reward: '\$90 stipend',
      tags: ['AI', 'Research', 'Slides'],
      safeForTeens: true,
      summary:
          'Collect a quick scan of AI tools solving the same problem. Highlight 3 differentiators and 2 risks.',
      deliverables: [
        '5-slide deck summarizing competitors',
        'Comparison table (pricing, features)',
        'One bold idea to stand out',
      ],
      safetyNotes: [
        'Use public sources only.',
        'No outreach or signups required.',
      ],
      xp: 90,
    ),
    const Mission(
      id: 'm3',
      title: 'Product explainer micro-video',
      startupName: 'Pulse Health',
      timeEstimate: '5-7 hrs',
      reward: '\$140 stipend',
      tags: ['Marketing', 'Video', 'Storytelling'],
      safeForTeens: false,
      summary:
          'Craft a 40-second vertical video explaining the product promise. Focus on clarity, calm pacing, and a confident CTA.',
      deliverables: [
        'Storyboard with 6-8 frames',
        'Final MP4 or link',
        'Caption file and CTA copy',
      ],
      safetyNotes: ['Avoid medical advice; use disclaimers where relevant.'],
      xp: 140,
    ),
    const Mission(
      id: 'm4',
      title: 'Landing page wireframe for beta',
      startupName: 'LumenOS',
      timeEstimate: '6 hrs',
      reward: '\$110 stipend',
      tags: ['Coding', 'Wireframe', 'UI'],
      safeForTeens: true,
      summary:
          'Design a responsive landing wireframe with a hero, proof, and CTA. Keep it focused on beta signups.',
      deliverables: [
        'Responsive wireframe (desktop + mobile)',
        'Component list with spacing tokens',
        'Copy notes for hero + CTA',
      ],
      safetyNotes: ['Use royalty-free assets only.'],
      xp: 110,
    ),
    const Mission(
      id: 'm5',
      title: 'Pitch one-page for investors',
      startupName: 'FlowGrid',
      timeEstimate: '3-4 hrs',
      reward: '\$85 stipend',
      tags: ['Business', 'Pitch', 'Story'],
      safeForTeens: false,
      summary:
          'Turn the messy notes into a crisp one-page pitch with market, traction, and a sharp ask. Tone: confident and concise.',
      deliverables: [
        'One-page PDF',
        'Key metrics callouts',
        'Suggested next steps',
      ],
      safetyNotes: ['Do not include confidential revenue numbers.'],
      xp: 85,
    ),
  ];

  static final badges = <BadgeModel>[
    const BadgeModel(
      id: 'b1',
      name: 'Onboarding Whisperer',
      description: 'Crafted a guided first-time UX that converts.',
      earnedFrom: 'BrightSeed Labs',
      color: Color(0xFF4C6FFF),
    ),
    const BadgeModel(
      id: 'b2',
      name: 'AI Scout',
      description: 'Mapped the landscape of emerging AI tools.',
      earnedFrom: 'Nova AI',
      color: Color(0xFF38BDF8),
    ),
    const BadgeModel(
      id: 'b3',
      name: 'Storyteller',
      description: 'Shipped a crisp 40s product explainer.',
      earnedFrom: 'Pulse Health',
      color: Color(0xFF8B5CF6),
    ),
  ];
}
