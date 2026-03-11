/// 10-minute guided script schedule.
///
/// Prompts are short on purpose; allow ~10–15s between prompts.
library;

class Round10Line {
  const Round10Line(this.startTimeSeconds, this.filename);

  final int startTimeSeconds;
  final String filename;
}

const round10Lines = <Round10Line>[
  // Start after preamble; these start at 60s.
  Round10Line(60, 'You’re_doing_well.'),
  Round10Line(75, 'Just_notice_the_thought.'),
  Round10Line(90, 'No_judgement.'),
  Round10Line(105, 'Stay_with_the_ball.'),
  Round10Line(120, 'Thought.'),
  Round10Line(135, 'Ball.'),
  Round10Line(150, 'Thought.'),
  Round10Line(165, 'Body.'),
  Round10Line(180, 'Ball.'),
  Round10Line(195, 'Take_a_slow_breath.'),

  // Body scan (one body part at a time)
  Round10Line(210, 'Notice_your_forehead.'),
  Round10Line(225, 'Notice_your_jaw.'),
  Round10Line(240, 'Notice_your_throat.'),
  Round10Line(255, 'Notice_your_chest.'),
  Round10Line(270, 'Notice_your_shoulders.'),
  Round10Line(285, 'Notice_your_arms.'),
  Round10Line(300, 'Notice_your_hands.'),
  Round10Line(315, 'Notice_your_belly.'),
  Round10Line(330, 'Notice_your_legs.'),
  Round10Line(345, 'Notice_your_feet.'),

  // Core prompts
  Round10Line(360, 'Let_the_thought_be_here.'),
  Round10Line(375, 'You_don’t_have_to_fix_it.'),
  Round10Line(390, 'Name_the_feeling.'),
  Round10Line(405, 'Just_one_word.'),
  Round10Line(420, 'You_can_feel_it.'),
  Round10Line(435, 'And_still_play.'),
  Round10Line(450, 'Add_some_space.'),
  Round10Line(465, 'I’m_having_the_thought_that…'),
  Round10Line(480, 'Say_it_gently.'),
  Round10Line(495, 'Then_come_back.'),
  Round10Line(510, 'Thought.'),
  Round10Line(525, 'Body.'),
  Round10Line(540, 'Ball.'),

  // Compassion + perspective
  Round10Line(555, 'If_you_drift,_that’s_normal.'),
  Round10Line(570, 'Just_return.'),
  Round10Line(585, 'Imagine_a_friend.'),
  Round10Line(600, 'What_would_you_say_'),
  Round10Line(615, 'Keep_it_kind.'),
  Round10Line(630, 'Zoom_out.'),
  Round10Line(645, 'Past.'),
  Round10Line(660, 'Present.'),
  Round10Line(675, 'Future.'),
  Round10Line(690, 'Now.'),

  // Closing
  Round10Line(705, 'Pick_one_steady_sentence.'),
  Round10Line(720, 'This_is_a_thought,_not_a_fact.'),
  Round10Line(735, 'Hold_it_softly.'),
  Round10Line(750, 'Keep_playing.'),
  Round10Line(765, 'Notice_any_change.'),
  Round10Line(780, 'Even_one_percent.'),
  Round10Line(795, 'Slow_breath.'),
  Round10Line(810, 'You’re_safe_right_now.'),
  Round10Line(825, 'Back_to_the_ball.'),
];
