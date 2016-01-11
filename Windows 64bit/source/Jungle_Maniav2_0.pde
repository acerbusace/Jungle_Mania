//imports the minim library
import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

//changes

//one.gainExperience() for every enemy death
//et5 removed on contact and health decrease

//player class
class Player {
  //true = the player will take damage if hit
  boolean takeDamage;
  //timer for takeDamage
  float damageTaken;
  //how fast damageTaken decays
  float damageTakenDecay;

  //player lvl
  int lvl;
  //player speed lvl
  int speedAttribute;
  //player power lvl
  int powerAttribute;
  //player defence lvl
  int defenceAttribute;
  //decides which player player img is displayed on screen
  int imgLvl;
  //direction the player is facing (rotation)
  float direction;
  //how much experience needed to lvl up
  float nextLevel;
  //current amount of player experience
  float experience;

  //player max health
  float maxHealth;
  //player current health
  float health;
  //how fast the health decays
  float healthDecay;
  //hunger precentage in decimal
  float hunger;
  //how fast hunger develops
  float hungerGain;
  //player max stamina
  float maxStamina;
  //player current stamina
  float stamina;
  //how fast stamina regenerates
  float staminaRegen;
  //player armor (enemyDamage - armor = damageTaken)
  float armor;

  //player position on screen
  PVector position;
  //previous position of the player on screen
  PVector oldP;
  //player max velocity
  float maxVelocity;
  //player current velocity
  PVector velocity;
  //player speed 
  float speed;
  //determines if the player is big enough, the texture of the player is updated
  float sSize;
  //player size
  float size;

  //if the player is jumping
  boolean jump;
  //starting max height the player can jump
  float sMaxHeight;
  //current max height the player can jump
  float maxHeight;
  //current jump height of the player
  float currentHeight;
  //how fast the players height increases
  float heightIncrease;
  //stamina cost to jump
  float jStamina;

  //if the player is boosting
  boolean boost;
  //direction of the boost
  PVector boostDirection;
  //the starting boost timer (how long the player is in boost)
  float startingBoostTimer;
  //current boost timer
  float currentBoostTimer;
  //how fast the boost timer decays
  float boostTimerDecay;
  //stamina cost to use boost
  float bStamina;

  //if the player is doing a basic attack (claw attack)
  boolean attackC;
  //size of the claw
  PVector aCSize;
  //current position of the claw (normal position + currentPAC)
  float currentPAC;
  //speed of the claw
  float aCSpeed;
  //used to determine the speed of the claw (player size / aCSpeedDivider)
  float aCSpeedDivider;
  //claw direction (up, down, left, right)
  int aCDirection;
  //damage the claw deals
  float aDamage;
  //knock back of the claw
  float aKnockback;
  //stamina cost to use basic attack
  float aStamina;

  //if the player is doing a spin attack
  boolean attackS;
  //size of the sprite of the spin attack
  PVector aSSize;
  //how fast the sprites changes
  float aSSpeed;
  //current index of the sprite
  float aSSprite;
  //starting cooldown of the spin attack
  float startingReloadTime;
  //current cooldown of the spin attack
  float currentReloadTime;
  //how fast the cooldown decays
  float reloadTimeDecay;
  //damage the spin attack deals
  float sDamage;
  //knock back of the spin attack
  float sKnockback;
  //stamina cost to use the spin attack
  float sStamina;

  //takes in the players posittion
  Player(PVector newP) {
    //assigns values to the created variables above
    takeDamage = true;
    damageTaken = 0;
    damageTakenDecay = 0.015*60;

    lvl = 1;
    speedAttribute = 1;
    powerAttribute = 1;
    defenceAttribute = 1;
    imgLvl = 0;
    direction = 0;
    nextLevel = 100;
    experience = 0;

    maxHealth = 100;
    health = maxHealth;
    healthDecay = 0.1*60;
    hunger = 0;
    hungerGain = 0.0002*60;
    maxStamina = 100;
    stamina = maxStamina;
    staminaRegen = 0.25*60;
    armor = 10;

    position = new PVector(newP.x, newP.y);
    oldP = new PVector(position.x, position.y);
    //maxvelocity to be decided
    maxVelocity = 150;
    velocity = new PVector(0, 0);
    speed = 225;

    sSize = 30;
    size = sSize;

    jump = false;
    sMaxHeight = 20;
    maxHeight = sMaxHeight;
    currentHeight = 0;
    heightIncrease = 0.75*60;
    jStamina = 33;

    boost = false;
    boostDirection = new PVector(0, 0);
    startingBoostTimer = 1;
    currentBoostTimer = startingBoostTimer;
    boostTimerDecay = 0.35*60;
    bStamina = 45;

    attackC = false;
    aCSize = new PVector(size, size/2);
    currentPAC = -aCSize.y;
    aCSpeedDivider = 10;
    aCSpeed = size/aCSpeedDivider*60;
    aDamage = 30;
    aKnockback = 5;
    aStamina = 40;

    attackS = false;
    aSSize = new PVector(size*3, size*3);
    aSSpeed = 0.5*60;
    aSSprite = 0;
    startingReloadTime = 1;
    reloadTimeDecay = 0.01*60;
    sDamage = 50;
    sKnockback = 2.5;
    sStamina = 60;
  }

  //updates the player position on the screen
  void updatePosition() {
    //saves the players current position
    oldP.x = position.x;
    oldP.y = position.y;

    //changes the player position
    position.x += velocity.x*ratio;
    position.y += velocity.y*ratio;
  }

  //updates the player's position on the screen (if the player is in boost)
  void updatePosition(float boostRatio) {
    //saves the players current position
    oldP.x = position.x;
    oldP.y = position.y;

    //changes the player position
    position.x += boostDirection.x*maxVelocity*boostRatio*ratio;
    position.y += boostDirection.y*maxVelocity*boostRatio*ratio;

    //if the boost timer is at zero, the boost is over
    if (currentBoostTimer <= 0) {
      currentBoostTimer = startingBoostTimer;
      boost = false;
    }

    //decreases the boost timer
    currentBoostTimer -= boostTimerDecay*ratio;
  }

  //reverts the player back to his previous position
  void backPosition() {
    position.x = oldP.x;
    position.y = oldP.y;
  }

  //reverts the player back to his previous position
  void backPosition(int xy) {
    //reverts the player in the x direction
    if (xy == 1) {
      position.x = oldP.x;
    } 
    //reverts the player in the y direction
    else if (xy == 2) {
      position.y = oldP.y;
    }
  }

  //updates the players velocity
  void updateVelocity() {
    //player changing direction multiplier
    float turnSpeed = 2;
    //player stoping multiplier
    float stopSpeed = 1.5;

    //decreases the player velocity in the x direction
    if (w) {
      //plays the player movement sound
      playSound(movementSound, 1);

      if (velocity.y > -maxVelocity) {
        if (velocity.y > 0) {
          velocity.y -= speed*turnSpeed*ratio;
        } else {
          velocity.y -= speed*ratio;
        }
      }
    }

    //increases the player velocity in the x direction
    if (s) {
      //plays the player movement sound
      playSound(movementSound, 1);
      if (velocity.y < maxVelocity) {
        if (velocity.y < 0) {
          velocity.y += speed*turnSpeed*ratio;
        } else {
          velocity.y += speed*ratio;
        }
      }
    }
    //decreases the player velocity in the y direction
    if (a) {
      //plays the player movement sound
      playSound(movementSound, 1);
      if (velocity.x > -maxVelocity) {
        if (velocity.x > 0) {
          velocity.x -= speed*turnSpeed*ratio;
        } else {
          velocity.x -= speed*ratio;
        }
      }
    }
    //increases the player velocity in the y direction
    if (d) {
      //plays the player movement sound
      playSound(movementSound, 1);
      if (velocity.x < maxVelocity) {
        if (velocity.x < 0) {
          velocity.x += speed*turnSpeed*ratio;
        } else {
          velocity.x += speed*ratio;
        }
      }
    }

    //if the player is nothing pressing w or s, the player velocity in the x direction slowly goes to zero
    if (!w && !s) {
      if (velocity.y > 0) {
        if (velocity.y - speed*stopSpeed*ratio < 0) {
          velocity.y = 0;
        } else {
          velocity.y -= speed*stopSpeed*ratio;
        }
      } 
      if (velocity.y < 0) {
        if (velocity.y + speed*stopSpeed*ratio > 0) {
          velocity.y = 0;
        } else {
          velocity.y += speed*stopSpeed*ratio;
        }
      }
    }

    //if the player is nothing pressing a or d, the player velocity in the x direction slowly goes to zero
    if (!a && !d) {
      if (velocity.x > 0) {
        if (velocity.x - speed*stopSpeed*ratio < 0) {
          velocity.x = 0;
        } else {
          velocity.x -= speed*stopSpeed*ratio;
        }
      } 
      if (velocity.x < 0) {
        if (velocity.x + speed*stopSpeed*ratio > 0) {
          velocity.x = 0;
        } else {
          velocity.x += speed*stopSpeed*ratio;
        }
      }
    }
  }

  //sets velocity to zero
  void resetVelocity() {
    velocity.x = 0;
    velocity.y = 0;
  }

  //updates the player jump
  void updateJump() {
    //increases the players height
    currentHeight += heightIncrease*ratio;

    //starts decreasing the players height, if the player has reached the max jump height
    if (currentHeight > maxHeight) {
      heightIncrease = -heightIncrease;
    }

    //resets variables related to jump, if the player lands
    if (currentHeight <= 0) {
      //plays the landing sound
      playSound(landingSound);
      heightIncrease = -heightIncrease;
      currentHeight = 0;
      jump = false;
    }
  }

  //updates the basic attack
  void updateAttackC() {
    //increases the claw position
    if ((currentPAC + aCSize.y) < size + aCSize.y) {
      currentPAC += aCSpeed*ratio;
    } else {
      currentPAC = -aCSize.y;
      attackC = false;
    }
  }

  //updates the spin attack
  void updateAttackS() {
    //increases the index of the sprite
    aSSprite += aSSpeed*ratio;

    //if the index is greater than the length of the sprite array, the spin attack is over
    if (aSSprite >= spin.length) {
      one.attackS = false;
      aSSprite = 0;
    }
  }

  //player lvl up (changes the attributes based on speed, power and defence)
  void lvlUp(int attribute) {
    lvl++;

    //speed
    if (attribute == 1) {
      speedAttribute++;

      maxStamina += 20;
      stamina = maxStamina;

      maxVelocity+=50;
      speed +=75;

      aCSpeedDivider -= 0.5;
      aSSpeed += 0.03*60;
    } 
    //power
    else if (attribute == 2) {
      powerAttribute++;

      aDamage += 15;
      aKnockback += 2;
      sDamage += 22.5;
      sKnockback += 1.5;
      size += 5;
    } 
    //defence
    else if (attribute == 3) {
      defenceAttribute++;

      maxHealth += 25;
      health = maxHealth;
      armor+=10;
      size += 7.5;
    }

    //level dependend stats
    maxHealth += 5;
    health = maxHealth;
    maxStamina += 5;
    stamina = maxStamina;
    maxHeight += 2.5;
    healthDecay -= 0.001*60;
    hungerGain -= 0.0000075*60;
    aKnockback += 1;
    sKnockback += 0.75;

    boostTimerDecay -= 0.01*60;
    reloadTimeDecay += 0.01*60;
    staminaRegen += 0.025*60;

    //re-calculates the basic attack claw size
    aCSize = new PVector(size, size/2);
    aSSize = new PVector(size, size/2);

    //checks if the players size has increased enough for it to updated to the next player texture
    if (size - sSize > 15 && imgLvl < 2) {
      playSound(monsterGrowl);
      sSize += 15;
      imgLvl++;
    }

    //re-calculates the basic attack claw speed
    aCSpeed = size/aCSpeedDivider*60;

    //re-calculates the size of the spin attack sprite
    aSSize.x = size*3;
    aSSize.y = size*3;

    //sets the current player experience to zero
    experience = 0;
    //the player needs more experience to get to the next level
    nextLevel*=2;
  }

  //the player gains experience
  void gainExperience(float gain) {
    experience += gain;
  }

  //updates the health of the palyer
  void updateHealth() {
    //decays the players height based on the value of hunger and healthDecay
    health -= healthDecay*pow(hunger, 2)*ratio;

    //plays the heartBeat sound if the player health ratio is below 1/3
    if (health/maxHealth < 1/3.0f) {
      playSound(heartBeat, 1);
    }

    //the player gains hunger
    hunger += hungerGain*ratio;
    if (hunger > 1) {
      hunger = 1;
    } else if (hunger<=0) {
      hunger = 0;
    }
  }

  void addHealth(float add) {
    health += add*maxHealth;
    if (health > maxHealth) {
      health = maxHealth;
    }
  }

  //if the player takes damage
  void takeDamage(float damage) {
    //if the player can take damage, the player takes damage and then is given a short invincibility time frame
    if (takeDamage && !one.jump) {
      //plays the damage taken sound
      playSound(damageTakenSound);

      //updates the players health based on the players armor and enemy damage
      if (damage - armor >= 1) {
        health -= damage - armor;
      } else {
        health--;
      }
      takeDamage = false;
      damageTaken = 1;
    }
  }

  //updates the players invincibility timer
  void updateDamageTaken() {
    if (damageTaken > 0) {
      damageTaken -= damageTakenDecay*ratio;
    } else {
      takeDamage = true;
    }
  }
}

class Obstacle {
  //if collsions should be checked for
  boolean check;
  //position of the obstacle
  PVector position;
  //previous position of the obstacle
  PVector oldP;
  //size of the obstacle
  PVector size;
  //type of obstacle (rect or ellipse)
  int type;
  //if the obstacle is an image, what index in the corresponding image array
  int imgType;

  //if the obstacle is an actual obstacle
  Obstacle(PVector newP, PVector newS, int newT) {
    //sets values for the variables
    check = true;
    position = new PVector(newP.x, newP.y);
    oldP = new PVector(position.x, position.y);
    size = new PVector(newS.x, newS.y);
    type = newT;
    imgType = -1;
  }

  //if the obstacle is an image
  Obstacle(PVector newP, PVector newS, int newT, int newImgType) {
    //sets values for the variables
    check = false;
    position = new PVector(newP.x, newP.y);
    oldP = new PVector(position.x, position.y);
    size = new PVector(newS.x, newS.y);
    type = newT;
    imgType = newImgType;
  }

  //checks for collision with the player
  boolean collision(Player ply) {
    if (check) {
      //if this obstacle is a rect
      if (type == 1) {
        if ((ply.position.x - ply.size/2) > position.x && (ply.position.x - ply.size/2) < (position.x + size.x) && ply.position.y > position.y && ply.position.y < (position.y + size.y)) {
          return true;
        }
        if ((ply.position.x + ply.size/2) > position.x && (ply.position.x + ply.size/2) < (position.x + size.x) && ply.position.y > position.y && ply.position.y < (position.y + size.y)) {
          return true;
        }
        if (ply.position.x > position.x && ply.position.x < (position.x + size.x) && (ply.position.y - ply.size/2) > position.y && (ply.position.y - ply.size/2) < (position.y + size.y)) {
          return true;
        }
        if (ply.position.x > position.x && ply.position.x < (position.x + size.x) && (ply.position.y + ply.size/2) > position.y && (ply.position.y + ply.size/2) < (position.y + size.y)) {
          return true;
        }
      } 
      //if this obstacle is an ellipse
      else if (type == 2) {
        if (dist(ply.position.x, ply.position.y, position.x, position.y) < size.x/2 + ply.size/2) {
          return true;
        }
      }
    }
    return false;
  }

  //checks for collision with an enemy
  boolean collision(Enemy e) {
    if (check) {
      //if this obstacle is a rect
      if (type == 1) {
        if ((e.position.x - e.size/2) > position.x && (e.position.x - e.size/2) < (position.x + size.x) && e.position.y > position.y && e.position.y < (position.y + size.y)) {
          return true;
        }
        if ((e.position.x + e.size/2) > position.x && (e.position.x + e.size/2) < (position.x + size.x) && e.position.y > position.y && e.position.y < (position.y + size.y)) {
          return true;
        }
        if (e.position.x > position.x && e.position.x < (position.x + size.x) && (e.position.y - e.size/2) > position.y && (e.position.y - e.size/2) < (position.y + size.y)) {
          return true;
        }
        if (e.position.x > position.x && e.position.x < (position.x + size.x) && (e.position.y + e.size/2) > position.y && (e.position.y + e.size/2) < (position.y + size.y)) {
          return true;
        }
      } 
      //if this obstacle is an ellipse
      else if (type == 2) {
        if (dist(e.position.x, e.position.y, position.x, position.y) < size.x/2 + e.size/2) {
          return true;
        }
      }
    }
    return false;
  }
}

//normal, slow, fast/hoppy, leaping, exploding
class Enemy {
  PVector position;
  PVector oldP;
  PVector velocity;
  int size;
  int health;
  int dmg;
  int enemyType;
  float direction = 0;
  boolean attacked=false;
  color colour;
  float acc;
  float maxSpeed;
  float healthV;

  boolean collision=false;

  boolean passive=true;
  int aggroRange;
  float aggroDistance;
  float norm;

  int passiveMovementTimer=0;

  int pTimer;

  int kbTimer=0;
  boolean aKB=false;
  boolean sKB=false;
  boolean KB=false;

  int eTimer=0;

  boolean alive=true;
  boolean eaten=false;

  float hungerV;

  Enemy(PVector newP) {
    position = new PVector(newP.x, newP.y);
    oldP = new PVector(position.x, position.y);

    velocity = new PVector(0, 0);
  }

  void display() {
    //fill(colour);
    //ellipse(position.x,position.y,size,size);

    if (alive) {
      if (velocity.x != 0 || velocity.y != 0) {
        if (dist(one.position.x, one.position.y, position.x, position.y) > one.size/2 + size/2) {
          direction = atan(velocity.y/velocity.x);
          if (velocity.x < 0) {
            direction += PI;
          }
        }
      }

      pushMatrix();
      translate(position.x, position.y);
      rotate(direction);
      image(enemySprite[enemyType], -size/2, -size/2, size, size); 
      popMatrix();
    } else {
      image(enemySprite[enemySprite.length - 1], position.x-size/2, position.y-size/2, size, size);
    }
  }

  float aggroDistance(Player p) {
    return dist(position.x, position.y, p.position.x, p.position.y);
  }

  void updatePosition() {
    oldP.x = position.x;
    oldP.y = position.y;

    position.x += velocity.x;
    position.y += velocity.y;
  }

  //sets velocity to zero
  void resetVelocity() {
    velocity.x = 0;
    velocity.y = 0;
  }

  //reverts the player back to his previous position
  void backPosition(int xy) {
    //reverts the player in the x direction
    if (xy == 1) {
      position.x = oldP.x;
    } 
    //reverts the player in the y direction
    else if (xy == 2) {
      position.y = oldP.y;
    }
  }

  void aggro(Player p, int s) {
    //chase the player
    velocity.x=p.position.x-position.x;
    velocity.y=p.position.y-position.y;

    norm=sqrt(sq(velocity.x)+sq(velocity.y));

    velocity.x=s*velocity.x/norm;
    velocity.y=s*velocity.y/norm;
  }

  void dealDamage(Player p) {
    p.takeDamage(dmg);
  }

  void dead(Player p) {
    velocity.x=0;
    velocity.y=0;
    colour=color(0, 0, 0);
    if ((e)&&(p.position.x+p.size/2>=position.x-size/2)&&(p.position.x-p.size/2<=position.x+size/2)&&(p.position.y-p.size/2<=position.y+size/2)&&(p.position.y+p.size/2>=position.y-size/2)) {
      playSound(eating, 1);
      eTimer++;
      p.velocity.x=0;
      p.velocity.y=0;
      if (eTimer>=35) {
        eaten=true;
        p.hunger=p.hunger-hungerV;
      }
    } else {
      eTimer=0;
    }
  }


  boolean attacked(Player p) {
    if (p.attackC) {
      if (p.aCDirection == 1) {
        if ((p.position.x-p.size/2+p.currentPAC+p.aCSize.y > position.x-size/2) && (p.position.x-p.size/2+p.currentPAC < position.x+size/2) && (p.position.y-p.size/2-p.aCSize.x < position.y+size/2) && (p.position.y-p.size/2 > position.y-size/2)) {
          return true;
        }
      } else if (p.aCDirection == 2) {
        if ((p.position.x+p.size/2-p.currentPAC > position.x-size/2) && (p.position.x+p.size/2-p.currentPAC-p.aCSize.y < position.x+size/2) && (p.position.y+p.size/2 < position.y+size/2) && (p.position.y+p.size/2+p.aCSize.x > position.y-size/2)) {
          return true;
        }
      } else if (p.aCDirection == 3) {
        if ((p.position.x-p.size/2 > position.x-size/2) && (p.position.x-p.size/2-p.aCSize.x < position.x+size/2) && (p.position.y+p.size/2-p.currentPAC-p.aCSize.y < position.y+size/2) && (p.position.y+p.size/2-p.currentPAC > position.y-size/2)) {
          return true;
        }
      } else if (p.aCDirection == 4) {
        if ((p.position.x+p.size/2+p.aCSize.x > position.x-size/2) && (p.position.x+p.size/2 < position.x+size/2) && (p.position.y-p.size/2+p.currentPAC < position.y+size/2) && (p.position.y-p.size/2+p.currentPAC+p.aCSize.y > position.y-size/2)) {
          return true;
        }
      }
    }
    if (p.attackS) {
      if (dist(position.x, position.y, p.position.x, p.position.y)<=p.aSSize.x+p.size/2+size/2) {
        print("``hit||");
        return true;
      }
    }
    return false;
  }


  void takeDamage(Player p) {
    //aKnockback sKnockback

    playSound(hitSound);

    if (p.attackC) {
      health=health-int(p.aDamage);
      KB=true;
      aKB=true;
    } else if (p.attackS) {
      health=health-int(p.sDamage);
      KB=true;
      sKB=true;
    }
  }

  void knockback(Player p) {

    if (aKB) {
      kbTimer++;

      if (kbTimer==1) {
        velocity.x=p.position.x-position.x;
        velocity.y=p.position.y-position.y;

        norm=sqrt(sq(velocity.x)+sq(velocity.y));

        velocity.x=-p.aKnockback*velocity.x/norm;
        velocity.y=-p.aKnockback*velocity.y/norm;
      } else if (kbTimer>=3) {
        aKB=false;
        KB=false;
        kbTimer=0;
      }
    } else if (sKB) {
      kbTimer++;

      if (kbTimer==1) {
        velocity.x=p.position.x-position.x;
        velocity.y=p.position.y-position.y;

        norm=sqrt(sq(velocity.x)+sq(velocity.y));

        velocity.x=-p.sKnockback*velocity.x/norm;
        velocity.y=-p.sKnockback*velocity.y/norm;
      } else if (kbTimer>=3) {
        sKB=false;
        KB=false;
        kbTimer=0;
      }
    }
  }
}

class EnemyType1 extends Enemy {
  EnemyType1(PVector newP) {
    super(newP);
    size = int(random(35, 50));
    enemyType = 0;

    if (size<=44) {
      health=75;
      maxSpeed=2.5;
      aggroRange=270;
      dmg=25;
      hungerV=0.15;
      healthV = 0.10;
    } else if (size>44) {
      health=100;
      maxSpeed=3.5;
      aggroRange=320;
      dmg=33;
      hungerV=0.20;
      healthV = 0.15;
    }

    acc=1;
  }

  void passiveMovement() {

    if (velocity.x>maxSpeed) {
      velocity.x=maxSpeed;
    } else if (velocity.x<-maxSpeed) {
      velocity.x=-maxSpeed;
    }

    if (velocity.y>maxSpeed) {
      velocity.y=maxSpeed;
    } else if (velocity.y<-maxSpeed) {
      velocity.y=-maxSpeed;
    }

    if (passiveMovementTimer<50 || (passiveMovementTimer>=150 && passiveMovementTimer<=200)) {
      velocity.x=velocity.x+acc;
      if (passiveMovementTimer==200) {
        passiveMovementTimer=0;
      }
    } else if (passiveMovementTimer>=50 && passiveMovementTimer<150) {
      velocity.x=velocity.x-acc;
    }
    passiveMovementTimer+=1;
  }
}

class EnemyType2 extends Enemy {
  EnemyType2(PVector newP) {
    super(newP);
    size = int(random(40, 65));
    enemyType = 1;

    if (size<=45) {
      health=100;
      aggroRange=300;
      dmg=33;
      hungerV=0.20;
      healthV = 0.25;
    } else if (size<=54) {
      health=130;
      aggroRange=350;
      dmg=43;
      hungerV=0.25;
      healthV = 0.30;
    } else if (size>54) {
      health=160;
      aggroRange=400;
      dmg=53;
      hungerV=0.30;
      healthV = 0.40;
    }

    colour=color(150, 20, 20);
    acc=1;
    maxSpeed=3;

    pTimer=0;
  }

  void passiveMovement() {

    if (velocity.x>maxSpeed) {
      velocity.x=maxSpeed;
    } else if (velocity.x<-maxSpeed) {
      velocity.x=-maxSpeed;
    }

    if (velocity.y>maxSpeed) {
      velocity.y=maxSpeed;
    } else if (velocity.y<-maxSpeed) {
      velocity.y=-maxSpeed;
    }

    if (passiveMovementTimer<50 || (passiveMovementTimer>=150 && passiveMovementTimer<=200)) {
      velocity.x=velocity.x+acc;
      if (passiveMovementTimer==200) {
        passiveMovementTimer=0;
      }
    } else if (passiveMovementTimer>=50 && passiveMovementTimer<150) {
      velocity.x=velocity.x-acc;
    }
    passiveMovementTimer+=1;
  }

  void pounce(Player p) {
    float s=7.5;
    pTimer++;

    if (pTimer<120) {
      velocity.x=p.position.x-position.x;
      velocity.y=p.position.y-position.y;

      norm=sqrt(sq(velocity.x)+sq(velocity.y));

      velocity.x=s/4*velocity.x/norm;
      velocity.y=s/4*velocity.y/norm;
    } else {

      velocity.x=p.position.x-position.x;
      velocity.y=p.position.y-position.y;

      norm=sqrt(sq(velocity.x)+sq(velocity.y));

      if (size<=35) {
        s=12;
      } else if (size<=45) {
        s=15;
      } else if (size>45) {
        s=20;
      }

      velocity.x=s*velocity.x/norm;
      velocity.y=s*velocity.y/norm;
      print("~~~~pounce~~~~");
    } 
    if (pTimer> 125) {
      pTimer=0;
    }
  }
}

class EnemyType3 extends Enemy {
  EnemyType3(PVector newP) {
    super(newP);
    size = int(random(55, 100));
    enemyType = 2;
    if (size<=65) {
      health=160;
      dmg=70;
      hungerV=0.30;
      healthV = 0.175;
    } else if (size<=79) {
      health=230;
      dmg=80;
      hungerV=0.35;

      healthV = 0.20;
    } else if (size>79) {
      health=300;
      dmg=90;
      hungerV=0.40;
      healthV = 0.225;
    }

    colour=color(255, 186, 215);
    acc=1;
    maxSpeed=3;
    aggroRange=300;
  }

  void passiveMovement() {

    if (velocity.x>maxSpeed) {
      velocity.x=maxSpeed;
    } else if (velocity.x<-maxSpeed) {
      velocity.x=-maxSpeed;
    }

    if (velocity.y>maxSpeed) {
      velocity.y=maxSpeed;
    } else if (velocity.y<-maxSpeed) {
      velocity.y=-maxSpeed;
    }

    if (passiveMovementTimer<50 || (passiveMovementTimer>=150 && passiveMovementTimer<=200)) {
      velocity.x=velocity.x+acc;
      if (passiveMovementTimer==200) {
        passiveMovementTimer=0;
      }
    } else if (passiveMovementTimer>=50 && passiveMovementTimer<150) {
      velocity.x=velocity.x-acc;
    }
    passiveMovementTimer+=1;
  }
}

class EnemyType4 extends Enemy {
  EnemyType4(PVector newP) {
    super(newP);
    size = int(random(40, 65));
    enemyType = 3;

    if (size<=49) {
      health=100;
      dmg=55;
      hungerV=0.20;
      healthV = 0.25;
    } else if (size>49) {
      health=150;
      dmg=80;
      hungerV=0.25;
      healthV = 0.35;
    }
    colour=color(255, 239, 135);
    acc=1;
    maxSpeed=3;

    aggroRange=300;
  }

  void passiveMovement() {

    if (velocity.x>maxSpeed) {
      velocity.x=maxSpeed;
    } else if (velocity.x<-maxSpeed) {
      velocity.x=-maxSpeed;
    }

    if (velocity.y>maxSpeed) {
      velocity.y=maxSpeed;
    } else if (velocity.y<-maxSpeed) {
      velocity.y=-maxSpeed;
    }

    if (passiveMovementTimer<50 || (passiveMovementTimer>=150 && passiveMovementTimer<=200)) {
      velocity.x=velocity.x+acc;
      if (passiveMovementTimer==200) {
        passiveMovementTimer=0;
      }
    } else if (passiveMovementTimer>=50 && passiveMovementTimer<150) {
      velocity.x=velocity.x-acc;
    }
    passiveMovementTimer+=1;
  }
}

class EnemyType5 extends Enemy {
  EnemyType5(PVector newP, int type) {
    super(newP);
    if (type==1) {
      size = int(random(60, 75));
    } else if (type==2) {
      size = int(random(75, 85));
    }
    enemyType = 4;
    if (size<=75) {
      dmg=99;
      hungerV=0.45;
      healthV = 0.50;
    } else if (size>75) {
      dmg=150;
      hungerV=0.55;
      healthV = 0.75;
    }
    health=1;
    colour=color(255, 61, 187);
    acc=1;
    maxSpeed=4;
    aggroRange=300;
  }

  void passiveMovement() {

    if (velocity.x>maxSpeed) {
      velocity.x=maxSpeed;
    } else if (velocity.x<-maxSpeed) {
      velocity.x=-maxSpeed;
    }

    if (velocity.y>maxSpeed) {
      velocity.y=maxSpeed;
    } else if (velocity.y<-maxSpeed) {
      velocity.y=-maxSpeed;
    }

    if (passiveMovementTimer<50 || (passiveMovementTimer>=150 && passiveMovementTimer<=200)) {
      velocity.x=velocity.x+acc;
      if (passiveMovementTimer==200) {
        passiveMovementTimer=0;
      }
    } else if (passiveMovementTimer>=50 && passiveMovementTimer<150) {
      velocity.x=velocity.x-acc;
    }
    passiveMovementTimer+=1;
  }
}

//keeps track of string texts and their position on the screen (used for the credits screen)
class Names {
  //what the text consists of
  String name;
  //x position of the text
  float xPos;
  //y position of the text
  float yPos;

  Names(String n, float x, float y) {
    //sets values for the variables
    name = n;
    xPos = x;
    yPos = y;
  }
}

//creates a new text font
PFont textFont;
//sets the size of the text font
final int fontSize = 30;
//creates an array of names (credits screen)
Names[] creditsNames;

//previous time
long prevTime;
//starting time
long startingTime;
//how much time has passed in the game
float timeCount;
//current time
long currTime;
//ratio between the previous timer and the current time
double ratio;

//opacity of night
float nightOpacity; 
//how fast nightOpacity changes
float nightOpacitySpeed;

Minim minim;
//sounds
AudioPlayer basicAttackSound, spinAttackSound, movementSound, boostSound, jumpSound, landingSound, damageTakenSound, hitSound, eating, heartBeat, buttonSound, backgroundMusic, storyMusic, monsterGrowl;

//keeps track of which screen the player is currently at
boolean mainScreen, creditScreen, playScreen, levelUpScreen, pauseScreen, gameOverScreen, paused; 

//images used in the various screens (hover = when the mouse hovers over the image)
PImage mainMenu, credits;
PImage startButton, startButtonHover, creditButton, creditButtonHover, MainMenuButton, MainMenuButtonHover;
PImage playAgainButton, playAgainButtonHover;

//health bar related images (bar, health color, hunger color, stamina color)
PImage []healthBar;

//boost ratio (boostRatio*maxVelocity)
float boostRatio;
//claw image
PImage claw;
//spin attack sprite
PImage []spin;
//player sprite
PImage []oneSprite;
//enemy sprites
PImage []enemySprite;
//shield image
PImage shield;
//plus button image
PImage levelUpUI;
//plus button hover image
PImage levelUpUIhover;

//if w, a, s, d are pressed
boolean w;
boolean s;
boolean a;
boolean d;

boolean e;

//when the player reaches the edge of the screen and everything relative to the player starts moving instead of the player
float playerBounds;

int et1Respawn;
int et2Respawn;
int et3Respawn;
int et4Respawn;
int et5Respawn;

//if there is collision between player and obstacles
boolean collision;
boolean aggro;

Player one;
ArrayList<EnemyType1> et1 = new ArrayList<EnemyType1>();
ArrayList<EnemyType2> et2 = new ArrayList<EnemyType2>();
ArrayList<EnemyType3> et3 = new ArrayList<EnemyType3>();
ArrayList<EnemyType4> et4 = new ArrayList<EnemyType4>();
ArrayList<EnemyType5> et5 = new ArrayList<EnemyType5>();

int et1RT;
int et2RT;
int et3RT;
int et4RT;
int et5RT;

//arrayList of obstacles
ArrayList<Obstacle> obs = new ArrayList<Obstacle>();
//array of story slides
PImage story[] = new PImage[4];
//current story slide index
float storyIndex;
//background image (game world map)
PImage bG;
//index of bG in arrayList of obstacles
int bGPosition;

//size of the screen
PVector size; //size.x = 1600

void setup() {
  //assigns values to the variables
  size = new PVector(1600, 1000); 
  //sets the size of the screen
  size(int(size.x/2), int(size.y/2));

  playerBounds = 400;

  minim = new Minim(this);
  basicAttackSound = minim.loadFile("basicAttack.wav");
  spinAttackSound = minim.loadFile("spinAttack.wav");
  movementSound = minim.loadFile("movement.wav");
  boostSound = minim.loadFile("boost.wav");
  jumpSound = minim.loadFile("jump.wav");
  landingSound = minim.loadFile("landing.wav");
  damageTakenSound = minim.loadFile("hit.mp3");
  hitSound = minim.loadFile("hitting.mp3");
  eating = minim.loadFile("eating.mp3");
  heartBeat = minim.loadFile("heartBeat.wav");
  buttonSound = minim.loadFile("button.wav");
  backgroundMusic = minim.loadFile("backgroundMusic.wav");
  storyMusic = minim.loadFile("storyMusic.mp3");
  monsterGrowl = minim.loadFile("monsterGrowl.mp3"); 

  textFont = loadFont ("AgencyFB-Reg-48.vlw");
  creditsNames = new Names[3];
  creditsNames[0] = new Names ("Alex Patel", 150, height);
  creditsNames[1] = new Names ("Ibrahim Helmy", 150, height + fontSize);
  creditsNames[2] = new Names ("Kevin Mound", 150, height + fontSize*2);

  storyIndex = 0;

  mainScreen = true;
  creditScreen = false;
  playScreen = false;
  levelUpScreen = false;
  pauseScreen = false;
  gameOverScreen = false;
  paused = false;

  mainMenu = loadImage("TittleBackGround.jpg");
  credits = loadImage("CreditScreen.png");
  levelUpUI = loadImage("Plus.png");
  levelUpUIhover = loadImage("PlusHover.png");
  startButton = loadImage("StartButton.png");
  startButtonHover = loadImage("StartButtonHover.png");
  creditButton = loadImage("CreditsButton.png");
  creditButtonHover = loadImage("CreditsButtonHover.png");
  MainMenuButton = loadImage("MainMenuButton.png");
  MainMenuButtonHover = loadImage("MainMenuButtonHover.png");
  playAgainButton = loadImage("PlayAgainButton.png");
  playAgainButtonHover = loadImage("PlayAgainButtonHover.png");

  story[0] = loadImage("Slide1.jpg");
  story[1] = loadImage("Slide2.jpg");
  story[2] = loadImage("Slide3.jpg");
  story[3] = loadImage("Slide4.jpg");

  bG = loadImage("GameWorld.jpg");

  boostRatio = 5;
  claw = loadImage("claw.png");
  spin = new PImage[8];
  spin[0] = loadImage("Spin1.png");
  spin[1] = loadImage("Spin2.png");
  spin[2] = loadImage("Spin3.png");
  spin[3] = loadImage("Spin4.png");
  spin[4] = loadImage("Spin5.png");
  spin[5] = loadImage("Spin6.png");
  spin[6] = loadImage("Spin7.png");
  spin[7] = loadImage("Spin8.png");

  healthBar = new PImage[7];
  healthBar[0] = loadImage("bar.png");
  healthBar[1] = loadImage("health.png");
  healthBar[2] = loadImage("hunger.png");
  healthBar[3] = loadImage("stamina.png");
  healthBar[4] = loadImage("HealthBar4.png");
  healthBar[5] = loadImage("HealthBar5.png");
  healthBar[6] = loadImage("HealthBarEmpty.png");

  oneSprite = new PImage[3];
  oneSprite[0] = loadImage ("CreatureRight1.png");
  oneSprite[1] = loadImage ("CreatureRight2.png");
  oneSprite[2] = loadImage ("CreatureRight3.png");
  shield = loadImage("Shield.png");

  enemySprite = new PImage[6];
  enemySprite[0] = loadImage("EnemyGrassy.png");
  enemySprite[1] = loadImage("EnemySnowy.png");
  enemySprite[2] = loadImage("EnemySandy.png");
  enemySprite[3] = loadImage("EnemyRocky.png");
  enemySprite[4] = loadImage("EnemyLava.png");
  enemySprite[5] = loadImage("EnemyDead.png");

  //sets values to the variables related to enemies and player
  reset();

  prevTime = System.currentTimeMillis();
}

void draw() {  
  currTime = System.currentTimeMillis();
  //calculates the time ratio between when the method was called
  ratio = (currTime - prevTime)/1000f;
  if (!paused && !(one.health < 0) && playScreen && !(storyIndex + 0.075 < story.length)) {
    timeCount += (currTime - prevTime)/1000f;

    nightOpacity += nightOpacitySpeed*ratio;

    if (nightOpacity >= 200 || nightOpacity <= 0) {
      nightOpacitySpeed = -nightOpacitySpeed;

      et1Respawn += 3;
      et2Respawn += 0;
      et3Respawn += 1.5;
      et4Respawn += 0.75;
      et5Respawn += 0.5;
    }
  }

  prevTime = System.currentTimeMillis();

  //clears the screen
  clear();


  //main screen
  if (mainScreen) {
    image(mainMenu, 0, 0, width, height);

    //draws the correct button images based on if the mouse is hovering over them or not
    if (mouseX > width/2 -  width/10/2 && mouseX < width/2 -  width/10/2 + width/10 && mouseY >  height/1.5 -  height/10/2 && mouseY <  height/1.5 -  height/10/2 + height/10) {
      image(startButtonHover, width/2 -  width/10/2, height/1.5 -  height/10/2, width/10, height/10);
    } else {
      image(startButton, width/2 -  width/10/2, height/1.5 -  height/10/2, width/10, height/10);
    }
    if (mouseX > width/2 -  width/10/2 && mouseX < width/2 -  width/10/2 + width/10 && mouseY > height/1.5 -  height/10/2 + height/10 + height/30 && mouseY < height/1.5 -  height/10/2 + height/10 + height/30 + height/10) {
      image(creditButtonHover, width/2 -  width/10/2, height/1.5 -  height/10/2 + height/10 + height/30, width/10, height/10);
    } else {
      image(creditButton, width/2 -  width/10/2, height/1.5 -  height/10/2 + height/10 + height/30, width/10, height/10);
    }
  } 
  //credit screen
  else if (creditScreen) {
    background(0);

    textFont(textFont, fontSize);
    fill(255);
    textAlign(CORNER, CORNER);

    for (int i = 0; i < creditsNames.length; i++) {
      text(creditsNames[i].name, creditsNames[i].xPos, creditsNames[i].yPos);

      creditsNames[i].yPos--;
    }

    image(credits, 0, 0, width, height);

    //draws the correct button images based on if the mouse is hovering over them or not
    if (mouseX > width/2 -  width/10/2 && mouseX < width/2 -  width/10/2 + width/10 && mouseY > height/1.5 -  height/10/2 + height/10 + height/30 && mouseY < height/1.5 -  height/10/2 + height/10 + height/30 + height/10) {
      image(MainMenuButtonHover, width/2 -  width/10/2, height/1.5 -  height/10/2 + height/10 + height/30, width/10, height/10);
    } else {
      image(MainMenuButton, width/2 -  width/10/2, height/1.5 -  height/10/2 + height/10 + height/30, width/10, height/10);
    }
  } 
  //game is being played
  else if (playScreen) {

    //story screen
    if (storyIndex + 0.075 < story.length) {
      playSound(storyMusic, 1);

      storyIndex += 0.075*ratio;

      image(story[(int)storyIndex], 0, 0, width, height);

      startingTime = System.currentTimeMillis();
    } 
    //game world
    else {
      //if the game is not paused or the game is not over
      if (!paused && !(one.health < 0)) {
        /* Calculations */

        //plays the background music
        playSound(backgroundMusic, 1);

        //everything relative to the player doesn't have to move
        boolean moveX = false;
        boolean moveY = false;

        //updates the players position
        if (one.boost) {
          one.updatePosition(boostRatio);
        } else {
          one.updatePosition();
        }

        //if the player reaches the playerbounds, move everthing relative to the player
        if (one.position.x < playerBounds/2 || one.position.x > (width - playerBounds/2)) {
          one.backPosition(1);
          moveX = true;
        }
        if (one.position.y < playerBounds/2 || one.position.y > (height - playerBounds/2)) {
          one.backPosition(2);
          moveY = true;
        }

        //if the player has collided with any obstacles
        collision = false;

        //moves everything relative to the player, if moveX and/or moveY are true
        for (int i = 0; i < obs.size (); i++) {
          if (moveX) {
            obs.get(i).oldP.x = obs.get(i).position.x;

            if (one.boost) {
              obs.get(i).position.x -= one.boostDirection.x*one.maxVelocity*boostRatio*ratio;
            } else {
              obs.get(i).position.x -= one.velocity.x*ratio;
            }
          }
          if (moveY) {
            obs.get(i).oldP.y = obs.get(i).position.y;

            if (one.boost) {
              obs.get(i).position.y -= one.boostDirection.y*one.maxVelocity*boostRatio*ratio;
            } else {
              obs.get(i).position.y -= one.velocity.y*ratio;
            }
          }
          //collision is true if the player collides with the obstacles
          if (obs.get(i).collision(one)) {
            collision = true;
          }
        }

        //if collision is true, the obstacles get reset back to their previous positions
        if (collision) {
          for (int i = 0; i < obs.size (); i++) {
            if (moveX) {
              obs.get(i).position.x = obs.get(i).oldP.x;
            }
            if (moveY) {
              obs.get(i).position.y = obs.get(i).oldP.y;
            }
          }

          //resets the players position and velocity
          one.backPosition();
          one.resetVelocity();

          //makes this false, so the enemies dont move relative to the players movement, if the player is colliding
          moveX = false;
          moveY = false;
        }

        //determines if there aren't enough enemies of any type
        if (et1.size()<et1Respawn) {
          et1RT++;
          //if enough time has passed, respawn a new enemy somewhere
          if (et1RT>=10) {
            boolean moveOn;
            int ran_et1_x_1;
            int ran_et1_y_1;
            do {
              moveOn = true;

              ran_et1_x_1=int(random(427 + obs.get(bGPosition).position.x, 3585 + obs.get(bGPosition).position.x ));
              ran_et1_y_1=int(random(1118 + obs.get(bGPosition).position.y, 1694 + obs.get(bGPosition).position.y));

              et1.add(new EnemyType1(new PVector(ran_et1_x_1, ran_et1_y_1)));

              for (int j = 0; j < obs.size (); j++) {
                if (obs.get(j).collision(et1.get(et1.size() - 1)) || (et1.get(et1.size() - 1).position.x > 0 && et1.get(et1.size() - 1).position.x < width &&  et1.get(et1.size() - 1).position.y > 0 && et1.get(et1.size() - 1).position.y < height)) {
                  moveOn = false;
                }
              }
              et1.remove(et1.size() - 1);
            }
            while (!moveOn);
            int ran_et1_x_2;
            int ran_et1_y_2;
            do {
              moveOn = true;

              ran_et1_x_2=int(random(164 + obs.get(bGPosition).position.x, 1209 + obs.get(bGPosition).position.x));
              ran_et1_y_2=int(random(560 + obs.get(bGPosition).position.y, 1118 + obs.get(bGPosition).position.y));

              et1.add(new EnemyType1(new PVector(ran_et1_x_2, ran_et1_y_2)));

              for (int j = 0; j < obs.size (); j++) {
                if (obs.get(j).collision(et1.get(et1.size() - 1)) || (et1.get(et1.size() - 1).position.x > 0 && et1.get(et1.size() - 1).position.x < width &&  et1.get(et1.size() - 1).position.y > 0 && et1.get(et1.size() - 1).position.y < height)) {
                  moveOn = false;
                }
              }
              et1.remove(et1.size() - 1);
            }
            while (!moveOn);
            int ran_et1_x_3;
            int ran_et1_y_3;
            do {
              moveOn = true;


              ran_et1_x_3=int(random(1840 + obs.get(bGPosition).position.x, 2889 + obs.get(bGPosition).position.x));
              ran_et1_y_3=int(random(1694 + obs.get(bGPosition).position.y, 4000 + obs.get(bGPosition).position.y));

              et1.add(new EnemyType1(new PVector(ran_et1_x_3, ran_et1_y_3)));

              for (int j = 0; j < obs.size (); j++) {
                if (obs.get(j).collision(et1.get(et1.size() - 1)) || (et1.get(et1.size() - 1).position.x > 0 && et1.get(et1.size() - 1).position.x < width &&  et1.get(et1.size() - 1).position.y > 0 && et1.get(et1.size() - 1).position.y < height) || (et1.get(et1.size() - 1).position.x > 0 && et1.get(et1.size() - 1).position.x < width &&  et1.get(et1.size() - 1).position.y > 0 && et1.get(et1.size() - 1).position.y < height)) {
                  moveOn = false;
                }
              }
              et1.remove(et1.size() - 1);
            }
            while (!moveOn);

            int ran_et1=int(random(1, 5));

            if (ran_et1==1) {
              et1.add(new EnemyType1(new PVector(ran_et1_x_2, ran_et1_y_2)));
            } else if ((ran_et1==2) || (ran_et1==3)) {
              et1.add(new EnemyType1(new PVector(ran_et1_x_1, ran_et1_y_1)));
            } else if ((ran_et1==4)||(ran_et1==5)) {
              et1.add(new EnemyType1(new PVector(ran_et1_x_3, ran_et1_y_3)));
            }

            et1RT=0;
            print("||||||||||||||||respawn||||||||||||||||||||");
          }
        }

        if (et2.size()<et2Respawn) {
          et2RT++;
          if (et2RT>=100) {
            boolean moveOn;
            int ran_et2_x;
            int ran_et2_y;
            do {
              moveOn = true;

              ran_et2_x=int(random(440 + obs.get(bGPosition).position.x, 1837 + obs.get(bGPosition).position.x));
              ran_et2_y=int(random(2384 + obs.get(bGPosition).position.y, 4357 + obs.get(bGPosition).position.y));

              et2.add(new EnemyType2(new PVector(ran_et2_x, ran_et2_y)));

              for (int j = 0; j < obs.size (); j++) {
                if (obs.get(j).collision(et2.get(et2.size() - 1)) || (et2.get(et2.size() - 1).position.x > 0 && et2.get(et2.size() - 1).position.x < width &&  et2.get(et2.size() - 1).position.y > 0 && et2.get(et2.size() - 1).position.y < height)) {
                  moveOn = false;
                }
              }
              et2.remove(et2.size() - 1);
            }
            while (!moveOn);

            et2.add(new EnemyType2(new PVector(ran_et2_x, ran_et2_y)));

            et2RT=0;
          }
        }

        if (et3.size()<et3Respawn) {
          et3RT++;
          if (et3RT>=100) {
            boolean moveOn;
            int ran_et3_x;
            int ran_et3_y;
            do {
              moveOn = true;
              ran_et3_x=int(random(1632 + obs.get(bGPosition).position.x, 8000 + obs.get(bGPosition).position.x));
              ran_et3_y=int(random(56 + obs.get(bGPosition).position.y, 921 + obs.get(bGPosition).position.y));

              et3.add(new EnemyType3(new PVector(ran_et3_x, ran_et3_y)));

              for (int j = 0; j < obs.size (); j++) {
                if (obs.get(j).collision(et3.get(et3.size() - 1)) || (et3.get(et3.size() - 1).position.x > 0 && et3.get(et3.size() - 1).position.x < width &&  et3.get(et3.size() - 1).position.y > 0 && et3.get(et3.size() - 1).position.y < height)) {
                  moveOn = false;
                }
              }
              et3.remove(et3.size() - 1);
            }
            while (!moveOn);

            et3.add(new EnemyType3(new PVector(ran_et3_x, ran_et3_y)));

            et3RT=0;
          }
        }

        if (et4.size()<et4Respawn) {
          et4RT++;
          if (et4RT>=100) {
            boolean moveOn;
            int ran_et4_x_1;
            int ran_et4_y_1;
            do {
              moveOn = true;

              ran_et4_x_1=int(random(4976 + obs.get(bGPosition).position.x, 8000 + obs.get(bGPosition).position.x));
              ran_et4_y_1=int(random(1128 + obs.get(bGPosition).position.y, 1993 + obs.get(bGPosition).position.y));

              et4.add(new EnemyType4(new PVector(ran_et4_x_1, ran_et4_y_1)));

              for (int j = 0; j < obs.size (); j++) {
                if (obs.get(j).collision(et4.get(et4.size() - 1)) || (et4.get(et4.size() - 1).position.x > 0 && et4.get(et4.size() - 1).position.x < width &&  et4.get(et4.size() - 1).position.y > 0 && et4.get(et4.size() - 1).position.y < height)) {
                  moveOn = false;
                }
              }
              et4.remove(et4.size() - 1);
            }
            while (!moveOn);

            int ran_et4_x_2;
            int ran_et4_y_2;
            do {
              moveOn = true;

              ran_et4_x_2=int(random(6416 + obs.get(bGPosition).position.x, 8000 + obs.get(bGPosition).position.x));
              ran_et4_y_2=int(random(1993 + obs.get(bGPosition).position.y, 2874 + obs.get(bGPosition).position.y));

              et4.add(new EnemyType4(new PVector(ran_et4_x_2, ran_et4_y_2)));

              for (int j = 0; j < obs.size (); j++) {
                if (obs.get(j).collision(et4.get(et4.size() - 1)) || (et4.get(et4.size() - 1).position.x > 0 && et4.get(et4.size() - 1).position.x < width &&  et4.get(et4.size() - 1).position.y > 0 && et4.get(et4.size() - 1).position.y < height)) {
                  moveOn = false;
                }
              }
              et4.remove(et4.size() - 1);
            }
            while (!moveOn);

            int ran_et4_x_3;
            int ran_et4_y_3;
            do {
              moveOn = true;

              ran_et4_x_3=int(random(7520 + obs.get(bGPosition).position.x, 8000 + obs.get(bGPosition).position.x));
              ran_et4_y_3=int(random(2874 + obs.get(bGPosition).position.y, 3483 + obs.get(bGPosition).position.y));

              et4.add(new EnemyType4(new PVector(ran_et4_x_3, ran_et4_y_3)));

              for (int j = 0; j < obs.size (); j++) {
                if (obs.get(j).collision(et4.get(et4.size() - 1)) || (et4.get(et4.size() - 1).position.x > 0 && et4.get(et4.size() - 1).position.x < width &&  et4.get(et4.size() - 1).position.y > 0 && et4.get(et4.size() - 1).position.y < height)) {
                  moveOn = false;
                }
              }
              et4.remove(et4.size() - 1);
            }
            while (!moveOn);

            int ran_et4=int(random(1, 7));

            if ((ran_et4>=1) && (ran_et4<=4)) {
              et4.add(new EnemyType4(new PVector(ran_et4_x_1, ran_et4_y_1)));
            } else if ((ran_et4==5) || (ran_et4==6)) {
              et4.add(new EnemyType4(new PVector(ran_et4_x_2, ran_et4_y_2)));
            } else if (ran_et4==7) {
              et4.add(new EnemyType4(new PVector(ran_et4_x_3, ran_et4_y_3)));
            }

            et4RT=0;
          }
        }

        if (et5.size()<et5Respawn) {
          et5RT++;
          if (et5RT>=100) {
            //smaller
            boolean moveOn;
            int ran_et5_x_1;
            int ran_et5_y_1;
            do {
              moveOn = true;

              ran_et5_x_1=int(random(3752 + obs.get(bGPosition).position.x, 5329 + obs.get(bGPosition).position.x));
              ran_et5_y_1=int(random(3180 + obs.get(bGPosition).position.y, 4333 + obs.get(bGPosition).position.y));

              et5.add(new EnemyType5(new PVector(ran_et5_x_1, ran_et5_y_1), 1));

              for (int j = 0; j < obs.size (); j++) {
                if (obs.get(j).collision(et5.get(et5.size() - 1)) || (et5.get(et5.size() - 1).position.x > 0 && et5.get(et5.size() - 1).position.x < width &&  et5.get(et5.size() - 1).position.y > 0 && et5.get(et5.size() - 1).position.y < height)) {
                  moveOn = false;
                }
              }
              et5.remove(et5.size() - 1);
            }
            while (!moveOn);

            int ran_et5_x_2;
            int ran_et5_y_2;
            do {
              moveOn = true;

              ran_et5_x_2=int(random(3760 + obs.get(bGPosition).position.x, 5161 + obs.get(bGPosition).position.x));
              ran_et5_y_2=int(random(2476 + obs.get(bGPosition).position.y, 3173 + obs.get(bGPosition).position.y));

              et5.add(new EnemyType5(new PVector(ran_et5_x_2, ran_et5_y_2), 1));

              for (int j = 0; j < obs.size (); j++) {
                if (obs.get(j).collision(et5.get(et5.size() - 1)) || (et5.get(et5.size() - 1).position.x > 0 && et5.get(et5.size() - 1).position.x < width &&  et5.get(et5.size() - 1).position.y > 0 && et5.get(et5.size() - 1).position.y < height)) {
                  moveOn = false;
                }
              }
              et5.remove(et5.size() - 1);
            }
            while (!moveOn);

            //larger
            int ran_et5_x_3;
            int ran_et5_y_3;
            do {
              moveOn = true;

              ran_et5_x_3=int(random(6288 + obs.get(bGPosition).position.x, 6685 + obs.get(bGPosition).position.x));
              ran_et5_y_3=int(random(2836 + obs.get(bGPosition).position.y, 4349 + obs.get(bGPosition).position.y));

              et5.add(new EnemyType5(new PVector(ran_et5_x_3, ran_et5_y_3), 2));

              for (int j = 0; j < obs.size (); j++) {
                if (obs.get(j).collision(et5.get(et5.size() - 1)) || (et5.get(et5.size() - 1).position.x > 0 && et5.get(et5.size() - 1).position.x < width &&  et5.get(et5.size() - 1).position.y > 0 && et5.get(et5.size() - 1).position.y < height)) {
                  moveOn = false;
                }
              }
              et5.remove(et5.size() - 1);
            }
            while (!moveOn);

            int ran_et5_x_4;
            int ran_et5_y_4;
            do {
              moveOn = true;

              ran_et5_x_4=int(random(6685 + obs.get(bGPosition).position.x, 7686 + obs.get(bGPosition).position.x));
              ran_et5_y_4=int(random(3524 + obs.get(bGPosition).position.y, 4349 + obs.get(bGPosition).position.y));

              et5.add(new EnemyType5(new PVector(ran_et5_x_4, ran_et5_y_4), 2));

              for (int j = 0; j < obs.size (); j++) {
                if (obs.get(j).collision(et5.get(et5.size() - 1)) || (et5.get(et5.size() - 1).position.x > 0 && et5.get(et5.size() - 1).position.x < width &&  et5.get(et5.size() - 1).position.y > 0 && et5.get(et5.size() - 1).position.y < height)) {
                  moveOn = false;
                }
              }
              et5.remove(et5.size() - 1);
            }
            while (!moveOn);

            int ran_et5=int(random(1, 9));

            if ((ran_et5>=1) && (ran_et5<=3)) {
              et5.add(new EnemyType5(new PVector(ran_et5_x_1, ran_et5_y_1), 1));
            } else if ((ran_et5>=4) && (ran_et5<=5)) {
              et5.add(new EnemyType5(new PVector(ran_et5_x_2, ran_et5_y_2), 1));
            } else if ((ran_et5==6)||(ran_et5==7)) {
              et5.add(new EnemyType5(new PVector(ran_et5_x_3, ran_et5_y_3), 2));
            } else if ((ran_et5==8)||(ran_et5==9)) {
              et5.add(new EnemyType5(new PVector(ran_et5_x_4, ran_et5_y_4), 2));
            }
            et5RT=0;
          }
        }

        //calculations for enemies
        for (int i = 0; i < et1.size (); i++) {
          //moving properly when the screen moves
          if (moveX) {
            if (one.boost) {
              et1.get(i).position.x -= one.boostDirection.x*one.maxVelocity*boostRatio*ratio;
            } else {
              et1.get(i).position.x -= one.velocity.x*ratio;
            }
          }
          if (moveY) {
            if (one.boost) {
              et1.get(i).position.y -= one.boostDirection.y*one.maxVelocity*boostRatio*ratio;
            } else {
              et1.get(i).position.y -= one.velocity.y*ratio;
            }
          }
          et1.get(i).updatePosition();

          //obstacle collision for enemies
          for (int j = 0; j < obs.size (); j++) {
            if (obs.get(j).collision(et1.get(i))) {
              et1.get(i).resetVelocity();
              et1.get(i).backPosition(1);
              et1.get(i).backPosition(2);
            }
          }

          et1.get(i).collision=false;

          //if the enemy gets attacked take damage
          if (et1.get(i).attacked==false && et1.get(i).attacked(one)) {
            print("hit");
            et1.get(i).attacked=true;
            et1.get(i).takeDamage(one);
            //if enemy loses all its health, die
            if ((et1.get(i).health<=0)&&(et1.get(i).alive)) {
              one.gainExperience(50);
              et1.get(i).alive=false;
              one.addHealth(et1.get(i).healthV);
            }
          }
          //one swing=one attack, not multiple attacks
          if (one.attackC==false && one.attackS==false) {
            et1.get(i).attacked=false;
          }
        }

        for (int i = 0; i < et2.size (); i++) {
          if (moveX) {
            if (one.boost) {
              et2.get(i).position.x -= one.boostDirection.x*one.maxVelocity*boostRatio*ratio;
            } else {
              et2.get(i).position.x -= one.velocity.x*ratio;
            }
          }
          if (moveY) {
            if (one.boost) {
              et2.get(i).position.y -= one.boostDirection.y*one.maxVelocity*boostRatio*ratio;
            } else {

              et2.get(i).position.y -= one.velocity.y*ratio;
            }
          }
          et2.get(i).updatePosition();

          for (int j = 0; j < obs.size (); j++) {
            if (obs.get(j).collision(et2.get(i))) {
              et2.get(i).resetVelocity();
              et2.get(i).backPosition(1);
              et2.get(i).backPosition(2);
            }
          }

          et2.get(i).collision=false;

          if (et2.get(i).attacked==false && et2.get(i).attacked(one)) {
            print("hit");
            et2.get(i).attacked=true;
            et2.get(i).takeDamage(one);
            if ((et2.get(i).health<=0)&&(et2.get(i).alive)) {
              one.gainExperience(200);
              et2.get(i).alive=false;
              one.addHealth(et2.get(i).healthV);
            }
          }
          if (one.attackC==false && one.attackS==false) {
            et2.get(i).attacked=false;
          }
        }

        for (int i = 0; i < et3.size (); i++) {
          if (moveX) {
            if (one.boost) {
              et3.get(i).position.x -= one.boostDirection.x*one.maxVelocity*boostRatio*ratio;
            } else {
              et3.get(i).position.x -= one.velocity.x*ratio;
            }
          }
          if (moveY) {
            if (one.boost) {
              et3.get(i).position.y -= one.boostDirection.y*one.maxVelocity*boostRatio*ratio;
            } else {
              et3.get(i).position.y -= one.velocity.y*ratio;
            }
          }
          et3.get(i).updatePosition();

          for (int j = 0; j < obs.size (); j++) {
            if (obs.get(j).collision(et3.get(i))) {
              et3.get(i).resetVelocity();
              et3.get(i).backPosition(1);
              et3.get(i).backPosition(2);
            }
          }

          et3.get(i).collision=false;

          if (et3.get(i).attacked==false && et3.get(i).attacked(one)) {
            print("hit");
            et3.get(i).attacked=true;
            et3.get(i).takeDamage(one);
            if ((et3.get(i).health<=0)&&(et3.get(i).alive)) {
              one.gainExperience(100);
              et3.get(i).alive=false;
              one.addHealth(et3.get(i).healthV);
            }
          }
          if (one.attackC==false && one.attackS==false) {
            et3.get(i).attacked=false;
          }
        }

        for (int i = 0; i < et4.size (); i++) {
          if (moveX) {
            if (one.boost) {
              et4.get(i).position.x -= one.boostDirection.x*one.maxVelocity*boostRatio*ratio;
            } else {
              et4.get(i).position.x -= one.velocity.x*ratio;
            }
          }
          if (moveY) {
            if (one.boost) {
              et4.get(i).position.y -= one.boostDirection.y*one.maxVelocity*boostRatio*ratio;
            } else {
              et4.get(i).position.y -= one.velocity.y*ratio;
            }
          }
          et4.get(i).updatePosition();

          for (int j = 0; j < obs.size (); j++) {
            if (obs.get(j).collision(et4.get(i))) {
              et4.get(i).resetVelocity();
              et4.get(i).backPosition(1);
              et4.get(i).backPosition(2);
            }
          }

          et4.get(i).collision=false;

          if (et4.get(i).attacked==false && et4.get(i).attacked(one)) {
            print("hit");
            et4.get(i).attacked=true;
            et4.get(i).takeDamage(one);
            if ((et4.get(i).health<=0)&&(et4.get(i).alive)) {
              one.gainExperience(75);
              et4.get(i).alive=false;
              one.addHealth(et4.get(i).healthV);
            }
          }
          if (one.attackC==false && one.attackS==false) {
            et4.get(i).attacked=false;
          }
        }

        for (int i = 0; i < et5.size (); i++) {
          if (moveX) {
            if (one.boost) {
              et5.get(i).position.x -= one.boostDirection.x*one.maxVelocity*boostRatio*ratio;
            } else {
              et5.get(i).position.x -= one.velocity.x*ratio;
            }
          }
          if (moveY) {
            if (one.boost) {
              et5.get(i).position.y -= one.boostDirection.y*one.maxVelocity*boostRatio*ratio;
            } else {
              et5.get(i).position.y -= one.velocity.y*ratio;
            }
          }
          et5.get(i).updatePosition();

          for (int j = 0; j < obs.size (); j++) {
            if (obs.get(j).collision(et5.get(i))) {
              et5.get(i).resetVelocity();
              et5.get(i).backPosition(1);
              et5.get(i).backPosition(2);
            }
          }

          et5.get(i).collision=false;

          if (et5.get(i).attacked==false && et5.get(i).attacked(one)) {
            print("hit");
            et5.get(i).attacked=true;
            et5.get(i).takeDamage(one);
            if ((et5.get(i).health<=0)&&(et5.get(i).alive)) {
              one.gainExperience(300);
              et5.get(i).alive=false;
              one.addHealth(et5.get(i).healthV);
            }
          }
          if (one.attackC==false && one.attackS==false) {
            et5.get(i).attacked=false;
          }
        }

        //updates the variables relative to the player (health, stamina)
        //updates the players actions, if they are being performed 
        if (one.jump) {
          one.updateJump();
        } else {
          one.updateVelocity();
        }

        if (one.attackC) {
          one.updateAttackC();
        }

        if (one.attackS) {
          one.updateAttackS();
        }

        if (one.currentReloadTime > 0) {
          one.currentReloadTime -= one.reloadTimeDecay*ratio;
        }

        if (!(one.jump || one.attackC || one.attackS || one.boost)) {
          one.stamina += one.staminaRegen*ratio;
          if (one.stamina > one.maxStamina) {
            one.stamina = one.maxStamina;
          }
        }

        one.updateHealth();

        if (one.experience >= one.nextLevel) {
          levelUpScreen = true;
        }

        one.updateDamageTaken();
      }

      /* Drawing */
      //draws the game world
      image(bG, obs.get(bGPosition).position.x, obs.get(bGPosition).position.y, obs.get(bGPosition).size.x, obs.get(bGPosition).size.y);

      for (int i=0; i<et1.size (); i++) {
        et1.get(i).display();
        if (et1.get(i).alive) {
          if (et1.get(i).KB) {
            et1.get(i).knockback(one);
          } else if (et1.get(i).aggroDistance(one)<=et1.get(i).aggroRange) {
            et1.get(i).passive=false;
            et1.get(i).aggroRange=400;
            if (et1.get(i).aggroDistance(one)>(one.size/2)+(et1.get(i).size/2)) {
              et1.get(i).aggro(one, 3);
            } else {
              et1.get(i).velocity.x=0;
              et1.get(i).velocity.y=0;
              et1.get(i).dealDamage(one);
            }
          } else {
            if (et1.get(i).passive==false) {
              et1.get(i).aggroRange=250;
              et1.get(i).velocity.x=0;
              et1.get(i).velocity.y=0;
              et1.get(i).passive=true;
            }
          }

          if (et1.get(i).passive==true) {
            et1.get(i).passiveMovement();
          }
        } else {
          et1.get(i).dead(one);
          if (et1.get(i).eaten) {
            et1.remove(i);
          }
        }
      }

      for (int i=0; i<et2.size (); i++) {
        et2.get(i).display();
        if (et2.get(i).alive) {
          if (et2.get(i).KB) {
            et2.get(i).knockback(one);
          } else if (et2.get(i).aggroDistance(one)<=et2.get(i).aggroRange) {
            et2.get(i).passive=false;
            et2.get(i).aggroRange=400;
            if (et2.get(i).aggroDistance(one)>(one.size/2)+(et2.get(i).size/2)) {
              et2.get(i).pounce(one);
            } else {
              et2.get(i).velocity.x=0;
              et2.get(i).velocity.y=0;
              et2.get(i).dealDamage(one);
            }
          } else {
            if (et2.get(i).passive==false) {
              et2.get(i).aggroRange=250;
              et2.get(i).velocity.x=0;
              et2.get(i).velocity.y=0;
              et2.get(i).passive=true;
            }
          }

          if (et2.get(i).passive==true) {
            et2.get(i).passiveMovement();
          }
        } else {
          et2.get(i).dead(one);
          if (et2.get(i).eaten) {
            et2.remove(i);
          }
        }
      }

      for (int i=0; i<et3.size (); i++) {
        et3.get(i).display();
        if (et3.get(i).alive) {
          if (et3.get(i).KB) {
            et3.get(i).knockback(one);
          } else if (et3.get(i).aggroDistance(one)<=et3.get(i).aggroRange) {
            et3.get(i).passive=false;
            et3.get(i).aggroRange=400;
            if (et3.get(i).aggroDistance(one)>(one.size/2)+(et3.get(i).size/2)) {
              et3.get(i).aggro(one, 2);
              if (et3.get(i).health<=70) {
                et3.get(i).velocity.x=-et3.get(i).velocity.x*2;
                et3.get(i).velocity.y=-et3.get(i).velocity.y*2;
              }
            } else {
              et3.get(i).velocity.x=0;
              et3.get(i).velocity.y=0;
              et3.get(i).dealDamage(one);
            }
          } else {
            if (et3.get(i).passive==false) {
              et3.get(i).aggroRange=250;
              et3.get(i).velocity.x=0;
              et3.get(i).velocity.y=0;
              et3.get(i).passive=true;
            }
          }

          if (et3.get(i).passive==true) {
            et3.get(i).passiveMovement();
          }
        } else {
          et3.get(i).dead(one);
          if (et3.get(i).eaten) {
            et3.remove(i);
          }
        }
      }

      for (int i=0; i<et4.size (); i++) {
        et4.get(i).display();
        if (et4.get(i).alive) {
          if (et4.get(i).KB) {
            et4.get(i).knockback(one);
          } else if (et4.get(i).aggroDistance(one)<=et4.get(i).aggroRange) {
            et4.get(i).passive=false;
            et4.get(i).aggroRange=400;
            if (et4.get(i).aggroDistance(one)>(one.size/2)+(et4.get(i).size/2)) {
              et4.get(i).aggro(one, 9);
            } else {
              et4.get(i).velocity.x=0;
              et4.get(i).velocity.y=0;
              et4.get(i).dealDamage(one);
            }
          } else {
            if (et4.get(i).passive==false) {
              et4.get(i).aggroRange=250;
              et4.get(i).velocity.x=0;
              et4.get(i).velocity.y=0;
              et4.get(i).passive=true;
            }
          }

          if (et4.get(i).passive==true) {
            et4.get(i).passiveMovement();
          }
        } else {
          et4.get(i).dead(one);
          if (et4.get(i).eaten) {
            et4.remove(i);
          }
        }
      }

      for (int i=0; i<et5.size (); i++) {
        et5.get(i).display();
        if (et5.get(i).alive) {
          if (et5.get(i).KB) {
            et5.get(i).knockback(one);
          } else if (et5.get(i).aggroDistance(one)<=et5.get(i).aggroRange) {
            et5.get(i).passive=false;
            et5.get(i).aggroRange=400;
            if (et5.get(i).aggroDistance(one)>(one.size/2)+(et5.get(i).size/2)) {
              et5.get(i).aggro(one, 12);
            } else {
              et5.get(i).dealDamage(one);
              et5.remove(i);
              break;
            }
          } else {
            if (et5.get(i).passive==false) {
              et5.get(i).aggroRange=250;
              et5.get(i).velocity.x=0;
              et5.get(i).velocity.y=0;
              et5.get(i).passive=true;
            }
          }

          if (et5.get(i).passive==true) {
            et5.get(i).passiveMovement();
          }
        } else {
          et5.get(i).dead(one);
          if (et5.get(i).eaten) {
            et5.remove(i);
          }
        }
      }

      //calculates the rotation radian on the players image based on the players velocity
      if (one.velocity.x != 0 || one.velocity.y != 0) {
        one.direction = atan(one.velocity.y/one.velocity.x);
        if (one.velocity.x < 0) {
          one.direction += PI;
        }
      }

      //draws the player image differently is the player is jumping
      if (one.jump) {
        noStroke();
        fill(0, 0, 0, 75);
        //calculates how high the player image should be drawn from its normal position
        float h = (one.currentHeight/one.sMaxHeight)*5;
        //draws the players shadow
        ellipse(one.position.x, one.position.y, one.size - h, one.size - h);
        stroke(1);

        //draws the player
        pushMatrix();
        translate(one.position.x, one.position.y - one.currentHeight);
        rotate(one.direction);
        image(oneSprite[one.imgLvl], -one.size/2, -one.size/2, one.size + h, one.size + h);
        popMatrix();
      } else {

        //draws the player
        pushMatrix();
        translate(one.position.x, one.position.y);
        rotate(one.direction);
        image(oneSprite[one.imgLvl], -one.size/2, -one.size/2, one.size, one.size);
        popMatrix();
      }

      //draws the basic attack (claw)
      if (one.attackC) {
        //up claw attack
        if (one.aCDirection == 1) {
          pushMatrix();
          translate(one.position.x - one.size/2 + one.currentPAC, one.position.y - one.size/2);
          rotate(-PI/2);
          image(claw, 0, 0, one.aCSize.x, one.aCSize.y);
          popMatrix();
        } 
        //down claw attack
        else if (one.aCDirection == 2) {
          pushMatrix();
          translate(one.position.x + one.size/2 - one.currentPAC, one.position.y + one.size/2);
          rotate(PI/2);
          image(claw, 0, 0, one.aCSize.x, one.aCSize.y);
          popMatrix();
        } 
        //left claw attack
        else if (one.aCDirection == 3) {
          pushMatrix();
          translate(one.position.x - one.size/2, one.position.y + one.size/2 - one.currentPAC);
          scale(-1.0, -1.0);
          image(claw, 0, 0, one.aCSize.x, one.aCSize.y);
          popMatrix();
        } 
        //right claw attack
        else if (one.aCDirection == 4) {
          image(claw, one.position.x + one.size/2, one.position.y - one.size/2 + one.currentPAC, one.aCSize.x, one.aCSize.y);
        }
      }

      //draws the spin attack
      if (one.attackS) {
        image(spin[(int)one.aSSprite], one.position.x - one.aSSize.x/2, one.position.y - one.aSSize.y/2, one.aSSize.x, one.aSSize.y);
      }

      fill(0, 0, 0, nightOpacity);
      rect(0, 0, width, height);

      //draws the UI stuff
      //drwas the health, hunger and stamina bars
      if (one.health > 0) {
        image(healthBar[1], 17.5, 13, (width/5 - 17*2)*(one.health/one.maxHealth), height/10 - 13.25*2);
      }
      image(healthBar[0], 0, 0, width/5, height/10);

      if (one.hunger > 0) {
        image(healthBar[2], 17.5, 13 + height/10, (width/5 - 17*2)*one.hunger, height/10 - 13.25*2);
      }
      image(healthBar[0], 0, height/10, width/5, height/10);

      if (one.stamina > 0) {
        image(healthBar[3], 17.5, 13 + height/10*2, (width/5 - 17*2)*(one.stamina/one.maxStamina), height/10 - 13.25*2);
      }
      image(healthBar[0], 0, height/10*2, width/5, height/10);

      fill(232, 210, 84);
      //draws the experience bar
      rect(0, height - height/100, one.experience/one.nextLevel*width, height/100);
      //draws the shield
      image(shield, fontSize, height - height/100 - height/10 - fontSize, width/15, height/10);
      //draw the weapon
      image(claw, width/15*3 + fontSize*2, height - height/100 - height/10 - fontSize, width/10, height/10);

      textFont(textFont, fontSize);
      fill(255);
      textAlign(CORNER, CENTER);
      //draws the armor and damage values
      text("Armor: " + str(one.armor), width/15 + fontSize, height - height/100 - fontSize - height/10/2);
      text("Claw: " + str(one.aDamage), width/15*4.65 + fontSize*2, height - height/100 - fontSize - height/10/2 - fontSize/2);
      text("Spin: " + str(one.sDamage), width/15*4.65 + fontSize*2, height - height/100 - fontSize - height/10/2 + fontSize/2);
      text("Days Survived: " + str(int(timeCount/120)), width - fontSize*6, fontSize);

      textFont(textFont, fontSize);
      fill(255);
      if (currTime - startingTime < 4000) {
        textAlign(CENTER, CENTER);
        text("SPECIMEN 97... explore, survive and conquer!", width/2, height/2);
      } else if (currTime - startingTime < 15000) {
        textAlign(CORNER, CORNER);
        text("The higher your hunger bar, the fast your health depletes", width/5, height/10 + fontSize*1.25);
      }
      
      textFont(textFont, fontSize);
      fill(255);
      textAlign(CENTER, CENTER);
      //lvl up screen
      if (levelUpScreen) {
        //lvl up related text
        text("LEVEL UP!, select which skill to evolve", width/2, height/1.5 - fontSize); 
        text("Speed: " + str(one.speedAttribute), width/4 - fontSize*3, height/1.25 - fontSize);
        text("Power: " + str(one.powerAttribute), width/2 - fontSize*2, height/1.25 - fontSize);
        text("Defence: " + str(one.defenceAttribute), width/1.25 - fontSize*3, height/1.25 - fontSize);

        //draws the correct button images based on if the mouse is hovering over them or not
        if (mouseX > width/4 + fontSize*(2) - fontSize*3 && mouseX < width/4 + fontSize*(2) - fontSize*3 + width/20 && mouseY > height/1.25 - height/15/2 - fontSize && mouseY < height/1.25 - height/15/2 - fontSize + height/15) {
          image(levelUpUIhover, width/4 + fontSize*(2) - fontSize*3, height/1.25 - height/15/2 - fontSize, width/20, height/15);
        } else {
          image(levelUpUI, width/4 + fontSize*(2) - fontSize*3, height/1.25 - height/15/2 - fontSize, width/20, height/15);
        }
        if (mouseX > width/2 + fontSize*(2) - fontSize*2 && mouseX < width/2 + fontSize*(2) - fontSize*2 + width/20 && mouseY > height/1.25 - height/15/2 - fontSize && mouseY < height/1.25 - height/15/2 - fontSize + height/15) {
          image(levelUpUIhover, width/2 + fontSize*(2) - fontSize*2, height/1.25 - height/15/2 - fontSize, width/20, height/15);
        } else {
          image(levelUpUI, width/2 + fontSize*(2) - fontSize*2, height/1.25 - height/15/2 - fontSize, width/20, height/15);
        }
        if (mouseX > width/1.25 + fontSize*(2.5) - fontSize*3 && mouseX < width/1.23 + fontSize*(2.5) - fontSize*3 + width/20 && mouseY > height/1.25 - height/15/2 - fontSize && mouseY < height/1.25 - height/15/2 - fontSize + height/15) {
          image(levelUpUIhover, width/1.25 + fontSize*(2.5) - fontSize*3, height/1.25 - height/15/2 - fontSize, width/20, height/15);
        } else {
          image(levelUpUI, width/1.25 + fontSize*(2.5) - fontSize*3, height/1.25 - height/15/2 - fontSize, width/20, height/15);
        }
      }

      textFont(textFont, fontSize*2);
      //game over screen
      if (one.health < 0) {
        //game over text
        text("Game Over!", width/2, height/2);

        //draws the correct button images based on if the mouse is hovering over them or not
        if (mouseX > width/2 -  width/10/2 && mouseX < width/2 -  width/10/2 + width/10 && mouseY >  height/1.5 -  height/10/2 && mouseY <  height/1.5 -  height/10/2 + height/10) {
          image(playAgainButtonHover, width/2 -  width/10/2, height/1.5 -  height/10/2, width/10, height/10);
        } else {
          image(playAgainButton, width/2 -  width/10/2, height/1.5 -  height/10/2, width/10, height/10);
        }
        if (mouseX > width/2 -  width/10/2 && mouseX < width/2 -  width/10/2 + width/10 && mouseY > height/1.5 -  height/10/2 + height/10 + height/30 && mouseY < height/1.5 -  height/10/2 + height/10 + height/30 + height/10) {
          image(MainMenuButtonHover, width/2 -  width/10/2, height/1.5 -  height/10/2 + height/10 + height/30, width/10, height/10);
        } else {
          image(MainMenuButton, width/2 -  width/10/2, height/1.5 -  height/10/2 + height/10 + height/30, width/10, height/10);
        }
      } else if (paused) {
        text("Paused!", width/2, height/2);
      }
    }
  }
}

public void reset() {
  //clears all the arrayLists
  et1.clear();
  et2.clear();
  et3.clear();
  et4.clear();
  et5.clear();

  timeCount = 0;
  nightOpacity = 0;
  nightOpacitySpeed = 1.67;

  et1Respawn = 15;
  et2Respawn = 20;
  et3Respawn = 25;
  et4Respawn = 15;
  et5Respawn = 20;

  //assigns values to player and enemy related variables
  one = new Player(new PVector(width/2, height/2));

  //clears the obstacles arrayList
  obs.clear();

  //adds all theobstacles
  //grass obstacles
  obs.add(new Obstacle(new PVector(-size.x + 730, size.y + 165), new PVector(125, 125), 2));
  obs.add(new Obstacle(new PVector(-size.x + 1000, 320), new PVector(125, 125), 2));
  obs.add(new Obstacle(new PVector(960, 585), new PVector(105, 105), 2));
  obs.add(new Obstacle(new PVector(360, -size.y*1 + 340), new PVector(150, 150), 2));
  obs.add(new Obstacle(new PVector(395, -size.y*1 + 505), new PVector(70, 70), 2));
  obs.add(new Obstacle(new PVector(-size.x*2 + 875, -10), new PVector(150, 150), 2));
  //lava obstacles
  obs.add(new Obstacle(new PVector(4137 - (size.x)*2 - playerBounds, 3662 - (size.y)*1 - playerBounds), new PVector(154, 154), 2));
  obs.add(new Obstacle(new PVector(5520 - (size.x)*2 - playerBounds, 3270 - (size.y)*1 - playerBounds), new PVector(150, 150), 2));
  obs.add(new Obstacle(new PVector(4211 - (size.x)*2 - playerBounds, 2842 - (size.y)*1 - playerBounds), new PVector(100, 100), 2));
  obs.add(new Obstacle(new PVector(4736 - (size.x)*2 - playerBounds, 2767 - (size.y)*1 - playerBounds), new PVector(70, 70), 2));

  //hedge (snomy region obstacle
  obs.add(new Obstacle(new PVector(673 - (size.x)*2 - playerBounds, 2193 - (size.y)*1 - playerBounds), new PVector(1516, 130), 1));
  obs.add(new Obstacle(new PVector(2078 - (size.x)*2 - playerBounds, 2322 - (size.y)*1 - playerBounds), new PVector(125, 679), 1));
  obs.add(new Obstacle(new PVector(1896 - (size.x)*2 - playerBounds, 2885 - (size.y)*1 - playerBounds), new PVector(183, 126), 1));
  obs.add(new Obstacle(new PVector(2083 - (size.x)*2 - playerBounds, 3392 - (size.y)*1 - playerBounds), new PVector(120, 999), 1));
  obs.add(new Obstacle(new PVector(1892 - (size.x)*2 - playerBounds, 3387 - (size.y)*1 - playerBounds), new PVector(196, 135), 1));

  //lava
  obs.add(new Obstacle(new PVector(5384 - (size.x)*2 - playerBounds, 3726 - (size.y)*1 - playerBounds), new PVector(875, 682), 1));
  obs.add(new Obstacle(new PVector(5757 - (size.x)*2 - playerBounds, 3597 - (size.y)*1 - playerBounds), new PVector(87, 135), 1));
  obs.add(new Obstacle(new PVector(5695 - (size.x)*2 - playerBounds, 3320 - (size.y)*1 - playerBounds), new PVector(373, 302), 1));
  obs.add(new Obstacle(new PVector(5685 - (size.x)*2 - playerBounds, 3014 - (size.y)*1 - playerBounds), new PVector(173, 302), 1));
  obs.add(new Obstacle(new PVector(5183 - (size.x)*2 - playerBounds, 3014 - (size.y)*1 - playerBounds), new PVector(498, 140), 1));
  obs.add(new Obstacle(new PVector(5193 - (size.x)*2 - playerBounds, 2809 - (size.y)*1 - playerBounds), new PVector(125, 202), 1));

  //water
  obs.add(new Obstacle(new PVector(7086 - (size.x)*2 - playerBounds, 1373 - (size.y)*1 - playerBounds), new PVector(1303, 86), 1));
  obs.add(new Obstacle(new PVector(6750 - (size.x)*2 - playerBounds, 1371 - (size.y)*1 - playerBounds), new PVector(333, 80), 1));
  obs.add(new Obstacle(new PVector(6257 - (size.x)*2 - playerBounds, 1377 - (size.y)*1 - playerBounds), new PVector(494, 45), 1));
  obs.add(new Obstacle(new PVector(6309 - (size.x)*2 - playerBounds, 1321 - (size.y)*1 - playerBounds), new PVector(152, 53), 1));
  obs.add(new Obstacle(new PVector(5204 - (size.x)*2 - playerBounds, 1394 - (size.y)*1 - playerBounds), new PVector(822, 61), 1));
  obs.add(new Obstacle(new PVector(5257 - (size.x)*2 - playerBounds, 1459 - (size.y)*1 - playerBounds), new PVector(333, 284), 1));
  obs.add(new Obstacle(new PVector(5186 - (size.x)*2 - playerBounds, 1464 - (size.y)*1 - playerBounds), new PVector(76, 164), 1));
  obs.add(new Obstacle(new PVector(5272 - (size.x)*2 - playerBounds, 1738 - (size.y)*1 - playerBounds), new PVector(69, 686), 1));

  obs.add(new Obstacle(new PVector(5447 - (size.x)*2 - playerBounds, 2361 - (size.y)*1 - playerBounds), new PVector(220, 170), 1));
  obs.add(new Obstacle(new PVector(5356 - (size.x)*2 - playerBounds, 2330 - (size.y)*1 - playerBounds), new PVector(101, 131), 1));

  obs.add(new Obstacle(new PVector(5724 - (size.x)*2 - playerBounds, 2518 - (size.y)*1 - playerBounds), new PVector(80, 80), 2));
  obs.add(new Obstacle(new PVector(5771 - (size.x)*2 - playerBounds, 2561 - (size.y)*1 - playerBounds), new PVector(80, 80), 2));
  obs.add(new Obstacle(new PVector(5826 - (size.x)*2 - playerBounds, 2604 - (size.y)*1 - playerBounds), new PVector(120, 120), 2));

  obs.add(new Obstacle(new PVector(5787 - (size.x)*2 - playerBounds, 2654 - (size.y)*1 - playerBounds), new PVector(307, 161), 1));
  obs.add(new Obstacle(new PVector(5788 - (size.x)*2 - playerBounds, 2815 - (size.y)*1 - playerBounds), new PVector(77, 199), 1));

  bGPosition = obs.size();
  obs.add(new Obstacle(new PVector((-size.x)*2 - playerBounds, (-size.y)*1 - playerBounds), new PVector(size.x*5 + playerBounds*2, size.y*4 + playerBounds*2), 1, 12)); //Background

  //left boundary
  obs.add(new Obstacle(new PVector(-size.x*2 - playerBounds, -size.y*1 - playerBounds), new PVector(playerBounds, size.y*4 + playerBounds*2), 1));
  //right boundary
  obs.add(new Obstacle(new PVector(size.x*3, -size.y*1 - playerBounds), new PVector(playerBounds, size.y*4 + playerBounds*2), 1));
  //top boundary
  obs.add(new Obstacle(new PVector(-size.x*2, -size.y*1 - playerBounds), new PVector(size.x*5, playerBounds), 1));
  //bottom boundary
  obs.add(new Obstacle(new PVector(-size.x*2, size.y*3), new PVector(size.x*5, playerBounds), 1));

  //enemy respawn timers being reset
  et1RT=0;
  et2RT=0;
  et3RT=0;
  et4RT=0;
  et5RT=0;


  //determines where to spawn the enemies accross the map in their specific zones
  for (int i=0; i<15; i++) {
    boolean moveOn;
    int ran_et1_x_1;
    int ran_et1_y_1;
    do {
      moveOn = true;

      ran_et1_x_1=int(random(427-3200, 3585-3200 ));
      ran_et1_y_1=int(random(1118-1000, 1694-1000));

      et1.add(new EnemyType1(new PVector(ran_et1_x_1, ran_et1_y_1)));

      for (int j = 0; j < obs.size (); j++) {
        if (obs.get(j).collision(et1.get(et1.size() - 1)) || (et1.get(et1.size() - 1).position.x > 0 && et1.get(et1.size() - 1).position.x < width &&  et1.get(et1.size() - 1).position.y > 0 && et1.get(et1.size() - 1).position.y < height)) {
          moveOn = false;
        }
      }
      et1.remove(et1.size() - 1);
    }
    while (!moveOn);
    int ran_et1_x_2;
    int ran_et1_y_2;
    do {
      moveOn = true;

      ran_et1_x_2=int(random(164-3200, 1209-3200));
      ran_et1_y_2=int(random(560-1000, 1118-1000));

      et1.add(new EnemyType1(new PVector(ran_et1_x_2, ran_et1_y_2)));

      for (int j = 0; j < obs.size (); j++) {
        if (obs.get(j).collision(et1.get(et1.size() - 1)) || (et1.get(et1.size() - 1).position.x > 0 && et1.get(et1.size() - 1).position.x < width &&  et1.get(et1.size() - 1).position.y > 0 && et1.get(et1.size() - 1).position.y < height)) {
          moveOn = false;
        }
      }
      et1.remove(et1.size() - 1);
    }
    while (!moveOn);
    int ran_et1_x_3;
    int ran_et1_y_3;
    do {
      moveOn = true;


      ran_et1_x_3=int(random(1840-3200, 2889-3200));
      ran_et1_y_3=int(random(1694-1000, 4000-1000));

      et1.add(new EnemyType1(new PVector(ran_et1_x_3, ran_et1_y_3)));

      for (int j = 0; j < obs.size (); j++) {
        if (obs.get(j).collision(et1.get(et1.size() - 1)) || (et1.get(et1.size() - 1).position.x > 0 && et1.get(et1.size() - 1).position.x < width &&  et1.get(et1.size() - 1).position.y > 0 && et1.get(et1.size() - 1).position.y < height)) {
          moveOn = false;
        }
      }
      et1.remove(et1.size() - 1);
    }
    while (!moveOn);

    int ran_et1=int(random(1, 5));

    if (ran_et1==1) {
      et1.add(new EnemyType1(new PVector(ran_et1_x_2, ran_et1_y_2)));
    } else if ((ran_et1==2) || (ran_et1==3)) {
      et1.add(new EnemyType1(new PVector(ran_et1_x_1, ran_et1_y_1)));
    } else if ((ran_et1==4)||(ran_et1==5)) {
      et1.add(new EnemyType1(new PVector(ran_et1_x_3, ran_et1_y_3)));
    }
  }

  for (int i=0; i<20; i++) {

    boolean moveOn;
    int ran_et2_x;
    int ran_et2_y;
    do {
      moveOn = true;

      ran_et2_x=int(random(440-3200, 1837-3200));
      ran_et2_y=int(random(2384-1000, 4357-1000));

      et2.add(new EnemyType2(new PVector(ran_et2_x, ran_et2_y)));

      for (int j = 0; j < obs.size (); j++) {
        if (obs.get(j).collision(et2.get(et2.size() - 1))) {
          moveOn = false;
        }
      }
      et2.remove(et2.size() - 1);
    }
    while (!moveOn);

    et2.add(new EnemyType2(new PVector(ran_et2_x, ran_et2_y)));
  }

  for (int i=0; i<25; i++) { 
    boolean moveOn;
    int ran_et3_x;
    int ran_et3_y;
    do {
      moveOn = true;
      ran_et3_x=int(random(1632-3200, 8000-3200));
      ran_et3_y=int(random(56-1000, 921-1000));

      et3.add(new EnemyType3(new PVector(ran_et3_x, ran_et3_y)));

      for (int j = 0; j < obs.size (); j++) {
        if (obs.get(j).collision(et3.get(et3.size() - 1))) {
          moveOn = false;
        }
      }
      et3.remove(et3.size() - 1);
    }
    while (!moveOn);

    et3.add(new EnemyType3(new PVector(ran_et3_x, ran_et3_y)));
  }

  for (int i=0; i<15; i++) {
    boolean moveOn;
    int ran_et4_x_1;
    int ran_et4_y_1;
    do {
      moveOn = true;

      ran_et4_x_1=int(random(4976-3200, 8000-3200));
      ran_et4_y_1=int(random(1128-1000, 1993-1000));

      et4.add(new EnemyType4(new PVector(ran_et4_x_1, ran_et4_y_1)));

      for (int j = 0; j < obs.size (); j++) {
        if (obs.get(j).collision(et4.get(et4.size() - 1))) {
          moveOn = false;
        }
      }
      et4.remove(et4.size() - 1);
    }
    while (!moveOn);

    int ran_et4_x_2;
    int ran_et4_y_2;
    do {
      moveOn = true;

      ran_et4_x_2=int(random(6416-3200, 8000-3200));
      ran_et4_y_2=int(random(1993-1000, 2874-1000));

      et4.add(new EnemyType4(new PVector(ran_et4_x_2, ran_et4_y_2)));

      for (int j = 0; j < obs.size (); j++) {
        if (obs.get(j).collision(et4.get(et4.size() - 1))) {
          moveOn = false;
        }
      }
      et4.remove(et4.size() - 1);
    }
    while (!moveOn);

    int ran_et4_x_3;
    int ran_et4_y_3;
    do {
      moveOn = true;

      ran_et4_x_3=int(random(7520-3200, 8000-3200));
      ran_et4_y_3=int(random(2874-1000, 3483-1000));

      et4.add(new EnemyType4(new PVector(ran_et4_x_3, ran_et4_y_3)));

      for (int j = 0; j < obs.size (); j++) {
        if (obs.get(j).collision(et4.get(et4.size() - 1))) {
          moveOn = false;
        }
      }
      et4.remove(et4.size() - 1);
    }
    while (!moveOn);

    int ran_et4=int(random(1, 7));

    if ((ran_et4>=1) && (ran_et4<=4)) {
      et4.add(new EnemyType4(new PVector(ran_et4_x_1, ran_et4_y_1)));
    } else if ((ran_et4==5) || (ran_et4==6)) {
      et4.add(new EnemyType4(new PVector(ran_et4_x_2, ran_et4_y_2)));
    } else if (ran_et4==7) {
      et4.add(new EnemyType4(new PVector(ran_et4_x_3, ran_et4_y_3)));
    }
  }

  for (int i=0; i<20; i++) {
    //smaller

    boolean moveOn;
    int ran_et5_x_1;
    int ran_et5_y_1;
    do {
      moveOn = true;

      ran_et5_x_1=int(random(3752-3200, 5329-3200));
      ran_et5_y_1=int(random(3180-1000, 4333-1000));

      et5.add(new EnemyType5(new PVector(ran_et5_x_1, ran_et5_y_1), 1));

      for (int j = 0; j < obs.size (); j++) {
        if (obs.get(j).collision(et5.get(et5.size() - 1))) {
          moveOn = false;
        }
      }
      et5.remove(et5.size() - 1);
    }
    while (!moveOn);

    int ran_et5_x_2;
    int ran_et5_y_2;
    do {
      moveOn = true;

      ran_et5_x_2=int(random(3760-3200, 5161-3200));
      ran_et5_y_2=int(random(2476-1000, 3173-1000));

      et5.add(new EnemyType5(new PVector(ran_et5_x_2, ran_et5_y_2), 1));

      for (int j = 0; j < obs.size (); j++) {
        if (obs.get(j).collision(et5.get(et5.size() - 1))) {
          moveOn = false;
        }
      }
      et5.remove(et5.size() - 1);
    }
    while (!moveOn);

    //larger
    int ran_et5_x_3;
    int ran_et5_y_3;
    do {
      moveOn = true;

      ran_et5_x_3=int(random(6288-3200, 6685-3200));
      ran_et5_y_3=int(random(2836-1000, 4349-1000));

      et5.add(new EnemyType5(new PVector(ran_et5_x_3, ran_et5_y_3), 2));

      for (int j = 0; j < obs.size (); j++) {
        if (obs.get(j).collision(et5.get(et5.size() - 1))) {
          moveOn = false;
        }
      }
      et5.remove(et5.size() - 1);
    }
    while (!moveOn);

    int ran_et5_x_4;
    int ran_et5_y_4;
    do {
      moveOn = true;

      ran_et5_x_4=int(random(6685-3200, 7686-3200));
      ran_et5_y_4=int(random(3524-1000, 4349-1000));

      et5.add(new EnemyType5(new PVector(ran_et5_x_4, ran_et5_y_4), 2));

      for (int j = 0; j < obs.size (); j++) {
        if (obs.get(j).collision(et5.get(et5.size() - 1))) {
          moveOn = false;
        }
      }
      et5.remove(et5.size() - 1);
    }
    while (!moveOn);

    int ran_et5=int(random(1, 9));

    if ((ran_et5>=1) && (ran_et5<=3)) {
      et5.add(new EnemyType5(new PVector(ran_et5_x_1, ran_et5_y_1), 1));
    } else if ((ran_et5>=4) && (ran_et5<=5)) {
      et5.add(new EnemyType5(new PVector(ran_et5_x_2, ran_et5_y_2), 1));
    } else if ((ran_et5==6)||(ran_et5==7)) {
      et5.add(new EnemyType5(new PVector(ran_et5_x_3, ran_et5_y_3), 2));
    } else if ((ran_et5==8)||(ran_et5==9)) {
      et5.add(new EnemyType5(new PVector(ran_et5_x_4, ran_et5_y_4), 2));
    }
  }
}

void mousePressed() {
  //main menu
  if (mainScreen) {
    //start button is pressed
    if (mouseX > width/2 -  width/10/2 && mouseX < width/2 -  width/10/2 + width/10 && mouseY >  height/1.5 -  height/10/2 && mouseY <  height/1.5 -  height/10/2 + height/10) {
      playSound(buttonSound, 1);
      mainScreen = false;
      playScreen = true;
      startingTime = System.currentTimeMillis();
    }
    //credits button is pressed
    if (mouseX > width/2 -  width/10/2 && mouseX < width/2 -  width/10/2 + width/10 && mouseY > height/1.5 -  height/10/2 + height/10 + height/30 && mouseY < height/1.5 -  height/10/2 + height/10 + height/30 + height/10) {
      playSound(buttonSound, 1);
      mainScreen = false;
      creditScreen = true;
    }
  } 
  //credits screen
  else if (creditScreen) {
    //main menu button is pressed
    if (mouseX > width/2 -  width/10/2 && mouseX < width/2 -  width/10/2 + width/10 && mouseY > height/1.5 -  height/10/2 + height/10 + height/30 && mouseY < height/1.5 -  height/10/2 + height/10 + height/30 + height/10) {
      playSound(buttonSound, 1);
      mainScreen = true;
      creditScreen = false;
      creditsNames[0].yPos = height;
      creditsNames[1].yPos = height + fontSize;
      creditsNames[2].yPos = height + fontSize*2;
    }
  } 
  //game is being played
  else if (playScreen) {
    //game over screen
    if (one.health < 0) {
      //play again button is pressed
      if (mouseX > width/2 -  width/10/2 && mouseX < width/2 -  width/10/2 + width/10 && mouseY >  height/1.5 -  height/10/2 && mouseY <  height/1.5 -  height/10/2 + height/10) {
        playSound(buttonSound, 1);
        reset();
      }
      //main menu button is pressed
      if (mouseX > width/2 -  width/10/2 && mouseX < width/2 -  width/10/2 + width/10 && mouseY > height/1.5 -  height/10/2 + height/10 + height/30 && mouseY < height/1.5 -  height/10/2 + height/10 + height/30 + height/10) {
        playSound(buttonSound, 1);
        mainScreen = true;
        playScreen = false;
        reset();
        stopSound();
      }
    } else {
      //lvl up screen
      if (levelUpScreen) {
        //lvl up speed attribute
        if (mouseX > width/4 + fontSize*(2) - fontSize*3 && mouseX < width/4 + fontSize*(2) - fontSize*3 + width/20 && mouseY > height/1.25 - height/15/2 - fontSize && mouseY < height/1.25 - height/15/2 - fontSize + height/15) {
          playSound(buttonSound, 1);
          one.lvlUp(1);
          levelUpScreen = false;
        } 
        //lvl up power attribute
        else if (mouseX > width/2 + fontSize*(2) - fontSize*2 && mouseX < width/2 + fontSize*(2) - fontSize*2 + width/20 && mouseY > height/1.25 - height/15/2 - fontSize && mouseY < height/1.25 - height/15/2 - fontSize + height/15) {
          playSound(buttonSound, 1);
          one.lvlUp(2);
          levelUpScreen = false;
        }
        //lvl up defence attribute 
        else if (mouseX > width/1.25 + fontSize*(2.5) - fontSize*3 && mouseX < width/1.23 + fontSize*(2.5) - fontSize*3 + width/20 && mouseY > height/1.25 - height/15/2 - fontSize && mouseY < height/1.25 - height/15/2 - fontSize + height/15) {
          playSound(buttonSound, 1);
          one.lvlUp(3);
          levelUpScreen = false;
        }
      }
    }
  }
}

//plays the given sound (if the sound is already being played, override it)
void playSound(AudioPlayer sound) {
  sound.play(0);
}

//plays the given sound (if the sound is already being played, don't override it)
void playSound(AudioPlayer sound, int option) {

  if (!sound.isPlaying()) {
    sound.play(0);
  }
}

//stops music from playing
void stopSound() {
  backgroundMusic.pause();
}

void keyPressed() {
  //if the game is not paused
  if (!paused) {
    //if the cooresponding keys are pressed, the cooresponding boolean values are set to true
    if (key=='w') {
      w = true;
    }
    if (key=='s') {
      s = true;
    }
    if (key=='a') {
      a = true;
    }
    if (key=='d') {
      d = true;
    }

    //boosts the player in the given direction and consumes the stamina required
    if (keyCode == 16 && !one.boost && one.stamina >= one.bStamina) {
      if (w && a) {
        //plays boost sound
        playSound(boostSound);
        one.boost = true;
        one.boostDirection.x = -1;
        one.boostDirection.y = -1;
        one.stamina -= one.bStamina;
        playSound(boostSound);
      } else if (w && d) {
        //plays boost sound
        playSound(boostSound);
        one.boost = true;
        one.boostDirection.x = 1;
        one.boostDirection.y = -1;
        one.stamina -= one.bStamina;
      } else if (s && a) {
        //plays boost sound
        playSound(boostSound);
        one.boost = true;
        one.boostDirection.x = -1;
        one.boostDirection.y = 1;
        one.stamina -= one.bStamina;
      } else if (s && d) {
        //plays boost sound
        playSound(boostSound);
        one.boost = true;
        one.boostDirection.x = 1;
        one.boostDirection.y = 1;
        one.stamina -= one.bStamina;
      } else if (w) {
        //plays boost sound
        playSound(boostSound);
        one.boost = true;
        one.boostDirection.x = 0;
        one.boostDirection.y = -1;
        one.stamina -= one.bStamina;
      } else if (s) {
        //plays boost sound
        playSound(boostSound);
        one.boost = true;
        one.boostDirection.x = 0;
        one.boostDirection.y = 1;
        one.stamina -= one.bStamina;
      } else if (a) {
        //plays boost sound
        playSound(boostSound);
        one.boost = true;
        one.boostDirection.x = -1;
        one.boostDirection.y = 0;
        one.stamina -= one.bStamina;
      } else if (d) {
        //plays boost sound
        playSound(boostSound);
        one.boost = true;
        one.boostDirection.x = 1;
        one.boostDirection.y = 0;
        one.stamina -= one.bStamina;
      }
    }

    //makes the player jump and consumes the stamina required
    if (!one.jump && !one.attackC && !one.attackS && one.stamina >= one.jStamina) {
      if (keyCode==32) {
        playSound(jumpSound);
        one.jump = true;
        one.stamina -= one.jStamina;
      }
    }

    //preforms the basic attack in the given direction and consumes the stamina required
    if (!one.jump && !one.attackC && !one.attackS && one.stamina >= one.aStamina) {
      if (keyCode==38) {
        //up
        //plays the basic attack sound
        playSound(basicAttackSound);
        one.aCDirection = 1;
        one.attackC = true;
        one.stamina -= one.aStamina;
      }
      if (keyCode==40) {
        //down
        //plays the basic attack sound
        playSound(basicAttackSound);
        one.aCDirection = 2;
        one.attackC = true;
        one.stamina -= one.aStamina;
      }
      if (keyCode==37) {
        //left
        //plays the basic attack sound
        playSound(basicAttackSound);
        one.aCDirection = 3;
        one.attackC = true;
        one.stamina -= one.aStamina;
      }
      if (keyCode==39) {
        //right
        //plays the basic attack sound
        playSound(basicAttackSound);
        one.aCDirection = 4;
        one.attackC = true;
        one.stamina -= one.aStamina;
      }
    }

    if (!one.jump && !one.attackC && !one.attackS) {
      //performs the spin attack and consumes the required stamina
      if (key=='q' && one.currentReloadTime <= 0 && one.stamina >= one.sStamina) {
        //plays the spin attack sound
        playSound(spinAttackSound);
        one.currentReloadTime = one.startingReloadTime;
        one.attackS = true;
        one.stamina -= one.sStamina;
      }
    }

    //for texting purposes
    if (key=='u') {
      one.lvlUp(1);
    }
    if (key=='i') {
      one.lvlUp(2);
    }
    if (key=='o') {
      one.lvlUp(3);
    }
  }
  //pauses and unpauses the game
  if (key=='p' && playScreen) {
    if (paused) {
      paused = false;
    } else {
      paused = true;
    }
  }

  //eating an animal
  if (key=='e') {
    e = true;
  }
}

void keyReleased() {
  //if the cooresponding keys are released, the cooresponding boolean values are set to false
  if (key=='w') {
    w = false;
  }
  if (key=='s') {
    s = false;
  }
  if (key=='a') {
    a = false;
  }
  if (key=='d') {
    d = false;
  }


  if (key=='e') {
    e = false;
  }
}

