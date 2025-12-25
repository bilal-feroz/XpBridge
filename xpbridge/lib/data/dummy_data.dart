import '../models/application.dart';
import '../models/startup_profile.dart';
import '../models/startup_role.dart';
import '../models/student_profile.dart';

class DummyData {
  static final industries = <String>[
    'Technology',
    'Healthcare',
    'Finance',
    'Education',
    'E-commerce',
    'Marketing',
    'Design',
    'AI/ML',
  ];

  static final skillPool = <String>[
    'Figma',
    'Canva',
    'Prompting',
    'User Research',
    'Copywriting',
    'Social Media',
    'Python',
    'JavaScript',
    'Flutter',
    'React',
    'No-code',
    'Pitching',
    'Market Sizing',
    'Data Analysis',
    'UI/UX Design',
    'Video Editing',
  ];

  static final startups = <StartupProfile>[
    StartupProfile(
      id: 's1',
      companyName: 'BrightSeed Labs',
      email: 'hello@brightseed.io',
      description:
          'Building the future of personalized learning with AI-powered education tools.',
      industry: 'Education',
      requiredSkills: ['Figma', 'UI/UX Design', 'User Research'],
      openRoles: [
        StartupRole(
          title: 'Product Design Intern',
          commitment: '10-15 hrs/week • Remote',
          description:
              'Work with our design lead to redesign the student dashboard and craft new onboarding flows.',
        ),
        StartupRole(
          title: 'Research Assistant',
          commitment: '5-8 hrs/week',
          description:
              'Help us run usability tests with students and synthesize insights into actionable recommendations.',
        ),
      ],
      websiteUrl: 'https://brightseed.io',
      projectDetails:
          'Looking for design interns to help redesign our student dashboard and create engaging onboarding experiences.',
      createdAt: DateTime(2024, 1, 15),
    ),
    StartupProfile(
      id: 's2',
      companyName: 'Nova AI',
      email: 'careers@nova-ai.com',
      description:
          'Cutting-edge AI research company focused on natural language processing and automation.',
      industry: 'AI/ML',
      requiredSkills: ['Python', 'Prompting', 'Data Analysis'],
      openRoles: [
        StartupRole(
          title: 'Prompt Engineering Fellow',
          commitment: '8-12 hrs/week • Remote-friendly',
          description:
              'Own small experiments that improve our LLM evaluation harness and prompt libraries.',
        ),
        StartupRole(
          title: 'Data Labeling Partner',
          commitment: '10 hrs/week',
          description:
              'Collaborate with research engineers to curate and label datasets for multilingual models.',
        ),
      ],
      websiteUrl: 'https://nova-ai.com',
      projectDetails:
          'Seeking students passionate about AI to help with research, data labeling, and prompt engineering.',
      createdAt: DateTime(2024, 2, 20),
    ),
    StartupProfile(
      id: 's3',
      companyName: 'Pulse Health',
      email: 'team@pulsehealth.co',
      description:
          'Digital health platform making wellness accessible through mobile-first experiences.',
      industry: 'Healthcare',
      requiredSkills: ['Flutter', 'UI/UX Design', 'Copywriting'],
      openRoles: [
        StartupRole(
          title: 'Flutter Mobile Contributor',
          commitment: '12-15 hrs/week • Hybrid',
          description:
              'Ship features for our patient app, improve performance, and collaborate with design on polish.',
        ),
        StartupRole(
          title: 'Content & Copy Intern',
          commitment: '6-8 hrs/week',
          description:
              'Craft empathetic in-app copy and support lifecycle campaigns for our wellness programs.',
        ),
      ],
      websiteUrl: 'https://pulsehealth.co',
      projectDetails:
          'Need mobile dev interns to help build new features and improve app performance.',
      createdAt: DateTime(2024, 3, 10),
    ),
    StartupProfile(
      id: 's4',
      companyName: 'FlowGrid',
      email: 'jobs@flowgrid.io',
      description:
          'Workflow automation for small businesses. Simplify your operations.',
      industry: 'Technology',
      requiredSkills: ['JavaScript', 'React', 'No-code'],
      openRoles: [
        StartupRole(
          title: 'Frontend Integrations Intern',
          commitment: '10 hrs/week • Remote',
          description:
              'Build no-code templates and React components that connect FlowGrid to popular SMB tools.',
        ),
      ],
      websiteUrl: 'https://flowgrid.io',
      projectDetails:
          'Looking for frontend developers to help build integrations and improve our dashboard.',
      createdAt: DateTime(2024, 4, 5),
    ),
    StartupProfile(
      id: 's5',
      companyName: 'LumenOS',
      email: 'hello@lumenos.dev',
      description:
          'Open-source operating system for creators. Lightweight, fast, and beautiful.',
      industry: 'Technology',
      requiredSkills: ['Python', 'UI/UX Design', 'Video Editing'],
      openRoles: [
        StartupRole(
          title: 'Developer Advocate Intern',
          commitment: '8 hrs/week • Remote',
          description:
              'Create tutorials and sample projects that help indie hackers adopt LumenOS.',
        ),
        StartupRole(
          title: 'UI Design Partner',
          commitment: '10 hrs/week',
          description:
              'Pair with our core designers to refine the settings experience and craft iconography.',
        ),
      ],
      websiteUrl: 'https://lumenos.dev',
      projectDetails:
          'Seeking contributors for UI design, documentation, and promotional content.',
      createdAt: DateTime(2024, 5, 1),
    ),
  ];

  static final students = <StudentProfile>[
    StudentProfile(
      id: 'st1',
      name: 'Alex Chen',
      email: 'alex.chen@university.edu',
      bio:
          'Computer Science student passionate about mobile development and AI.',
      education: 'BSc Computer Science - Stanford University',
      skills: ['Flutter', 'Python', 'Figma', 'UI/UX Design'],
      availabilityHours: 15,
      portfolioUrl: 'https://alexchen.dev',
      createdAt: DateTime(2024, 1, 10),
    ),
    StudentProfile(
      id: 'st2',
      name: 'Sarah Miller',
      email: 'sarah.m@college.edu',
      bio:
          'Design student with a love for creating beautiful user experiences.',
      education: 'BA Graphic Design - RISD',
      skills: ['Figma', 'Canva', 'UI/UX Design', 'User Research'],
      availabilityHours: 20,
      portfolioUrl: 'https://sarahmiller.design',
      createdAt: DateTime(2024, 2, 5),
    ),
    StudentProfile(
      id: 'st3',
      name: 'James Wilson',
      email: 'jwilson@tech.edu',
      bio: 'Full-stack developer interested in startups and entrepreneurship.',
      education: 'MSc Software Engineering - MIT',
      skills: ['JavaScript', 'React', 'Python', 'Data Analysis'],
      availabilityHours: 10,
      portfolioUrl: 'https://jameswilson.io',
      createdAt: DateTime(2024, 3, 15),
    ),
    StudentProfile(
      id: 'st4',
      name: 'Emily Rodriguez',
      email: 'emily.r@marketing.edu',
      bio:
          'Marketing major with experience in social media and content creation.',
      education: 'BA Marketing - NYU',
      skills: ['Social Media', 'Copywriting', 'Video Editing', 'Canva'],
      availabilityHours: 25,
      createdAt: DateTime(2024, 4, 20),
    ),
    StudentProfile(
      id: 'st5',
      name: 'David Kim',
      email: 'dkim@ai.edu',
      bio: 'AI researcher focused on NLP and machine learning applications.',
      education: 'PhD Candidate - AI Lab, Berkeley',
      skills: ['Python', 'Prompting', 'Data Analysis', 'Market Sizing'],
      availabilityHours: 12,
      createdAt: DateTime(2024, 5, 10),
    ),
  ];

  static final applications = <Application>[
    Application(
      id: 'a1',
      studentId: 'st1',
      startupId: 's3',
      studentName: 'Alex Chen',
      startupName: 'Pulse Health',
      roleTitle: 'Flutter Mobile Contributor',
      status: ApplicationStatus.pending,
      message: 'I would love to contribute to your mobile app development!',
      appliedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Application(
      id: 'a2',
      studentId: 'st2',
      startupId: 's1',
      studentName: 'Sarah Miller',
      startupName: 'BrightSeed Labs',
      roleTitle: 'Product Design Intern',
      status: ApplicationStatus.interviewing,
      message: 'Your mission to improve education aligns with my passion.',
      appliedAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
}
