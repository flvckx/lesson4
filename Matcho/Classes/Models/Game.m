//
//  Game.m
//  Matcho
//
//  Created by Anton Lookin on 10/27/15.
//  Copyright © 2015 geekub. All rights reserved.
//

#import "Game.h"

@interface Game ()

@property (nonatomic, readwrite) NSInteger score;
@property (nonatomic, strong) NSMutableArray *cards;
@property (nonatomic, readwrite) NSString *message;

@end


@implementation Game


- (instancetype)initWithCardCount:(NSUInteger)count
						usingDeck:(Deck *)deck {
	self = [super init];
	
	if (self) {
		for (NSUInteger i = 0; i < count; i++) {
			Card *card = [deck drawRandomCard];
			
			if (card) {
				[self.cards addObject:card];
			} else {
				self = nil;
				break;
			}
		}
	}
	
	return self;
}


- (NSMutableArray *)cards {
	if (!_cards) _cards = [[NSMutableArray alloc] init];
	return _cards;
}


static const int MISMATCH_PENALTY = 2;
static const int MATCH_BONUS = 4;
static const int COST_TO_CHOOSE = 1;
static const int DOUBLE_MATCH_BONUS = 5;


- (void)chooseCardAtIndex:(NSUInteger)index {
	Card *card = [self cardAtIndex:index];
    Card *previousCard;
    
	if (!card.isMatched) {
		if (card.isChosen) {
			card.chosen = NO;
            self.message = [NSString stringWithFormat:@"You've put back the card %@, score hasn't changed.", card.contents];
		} else {
			NSMutableArray *chosenCards = [[NSMutableArray alloc] init];
			
			for (Card *otherCard in self.cards) {
				if (otherCard.isChosen && !otherCard.isMatched) {
					[chosenCards addObject:otherCard];
				}
			}
			
			if ([chosenCards count]) {
				int matchScore = [card match:chosenCards];
				if (matchScore) {
					self.score += (matchScore * MATCH_BONUS);
					
					card.chosen = YES;
					card.matched = YES;
					for (Card *otherCard in chosenCards) {
						otherCard.matched = YES;
                        previousCard = otherCard;
					}
                    
                    if ((([card.contents containsString:@"♣"] || [card.contents containsString:@"♠"])
                        && ([previousCard.contents containsString:@"♣"] || [card.contents containsString:@"♠"]))
                        || (([card.contents containsString:@"♦"] || [card.contents containsString:@"♥"])
                        && ([previousCard.contents containsString:@"♦"] || [card.contents containsString:@"♥"]))) {
                            self.score += (matchScore * DOUBLE_MATCH_BONUS);
                            self.message = [NSString stringWithFormat:@"Well done! Cards %@ and %@ are matched, you score %i.", previousCard.contents, card.contents, (matchScore * MATCH_BONUS) + (matchScore * DOUBLE_MATCH_BONUS)];
                        } else {
                            self.message = [NSString stringWithFormat:@"Well done! Cards %@ and %@ are matched, you score %i.", previousCard.contents, card.contents, (matchScore * MATCH_BONUS)];
                        }
				} else {
					int penalty = MISMATCH_PENALTY;
					
					self.score -= penalty;
					card.chosen = YES;
					for (Card *otherCard in chosenCards) {
						otherCard.chosen = NO;
                        previousCard = otherCard;
					}
                    self.message = [NSString stringWithFormat:@"Cards %@ and %@ are mismatched, you lose %i.", previousCard.contents, card.contents, MISMATCH_PENALTY];
				}
			} else {
				self.score -= COST_TO_CHOOSE;
                self.message = [NSString stringWithFormat:@"You've drawn %@, you lose %i.", card.contents, COST_TO_CHOOSE];
				card.chosen = YES;
			}
		}
	}
}


- (Card *)cardAtIndex:(NSUInteger)index {
	return (index < [self.cards count]) ? self.cards[index] : nil;
}


@end
