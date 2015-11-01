//
//  ViewController.m
//  Matcho
//
//  Created by Anton Lookin on 10/19/15.
//  Copyright © 2015 geekub. All rights reserved.
//

#import "Game.h"
#import "PlayingCardDeck.h"

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) Game *game;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cardButtons;

@end

@implementation ViewController


- (Game *)game {
	if (!_game) {
		_game = [[Game alloc] initWithCardCount:[self.cardButtons count]
									  usingDeck:[[PlayingCardDeck alloc] init]];
	}
	return _game;
}


- (IBAction)cardButtonTapped:(UIButton *)sender {
	NSUInteger cardIndex = [self.cardButtons indexOfObject:sender];
    
    [self.game chooseCardAtIndex:cardIndex];
    
    [myLabelForScore setText:[NSString stringWithFormat:@"Your score is %li", self.game.score]];
    [myLabelForInfo setText:self.game.message];
	
    [self updateUI];
}


-(void) updateUI {
	for (UIButton *cardButton in self.cardButtons) {
		NSUInteger cardIndex = [self.cardButtons indexOfObject:cardButton];
		Card *card = [self.game cardAtIndex:cardIndex];
		
		[cardButton setTitle:[self titleForCard:card] forState:UIControlStateNormal];
		[cardButton setBackgroundImage:[self backgroundImageForCard:card]
							  forState:UIControlStateNormal];
		cardButton.enabled = !card.isMatched;
	}
    int i = 0;
    for (UIButton *cardButton in self.cardButtons) {
        if (cardButton.enabled) {
            i++;
        }
    }
    NSMutableArray *lastCardsToMatch = [[NSMutableArray alloc] init];
    if (i == 2) {
        for (UIButton *cardButton in self.cardButtons) {
            if (cardButton.enabled) {
                PlayingCard *card = [[PlayingCard alloc] initWithSuit:[cardButton.titleLabel.text substringFromIndex:1] andRank:[cardButton.titleLabel.text intValue]];
                [lastCardsToMatch addObject:card];
            }
        }
        if ([[[lastCardsToMatch objectAtIndex:0] suit] isEqualToString:[[lastCardsToMatch objectAtIndex:1] suit]]
            || [[lastCardsToMatch objectAtIndex:0] rank] == [[lastCardsToMatch objectAtIndex:1] rank]) {
        } else {
            [myLabelForInfo setText:@"Game Over. There're no cards to match."];
            for (UIButton *cardButton in self.cardButtons) {
                if (cardButton.enabled) {
                    cardButton.enabled = NO;
                }
            }
        }
    }
}


-(NSString *) titleForCard:(Card *)card {
	return (card.isChosen) ? card.contents : @"";
}


-(UIImage *) backgroundImageForCard:(Card *)card {
	return [UIImage imageNamed:(card.isChosen) ? @"cardfront" : @"cardback"];
}


@end
